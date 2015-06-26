//
//  BuildTourDetailViewController.m
//  Tours
//
//  Created by Gretchen Walker on 6/22/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BuildTourDetailViewController.h"
#import "TourPhotoCollectionViewCell.h"
#import "BuildTourStopsViewController.h"
#import "StopPointAnnotation.h"
#import "SummaryTextView.h"
#import "Tour.h"
#import "Stop.h"
#import "Photo.h"
#import <MapKit/MapKit.h>
#import <ParseUI/ParseUI.h>

@interface BuildTourDetailViewController () <MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, SummaryTextViewDelegate>

@property (weak, nonatomic) IBOutlet PFImageView *coverPhotoImageView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
//@property (weak, nonatomic) IBOutlet UILabel *stopTitle;
@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;
@property (weak, nonatomic) IBOutlet UIView *tourDetailView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tourDetailViewHeightConstraint;

@property UILabel *totalDistanceLabel;
@property UILabel *estimatedTimeLabel;
@property UILabel *distanceFromCurrentLocationLabel;
@property UILabel *ratingsLabel;
@property SummaryTextView *summaryTextView;
@property UIButton *moreButton;
@property UIButton *editStopsButton;

@property NSArray *stops;
@property NSMutableDictionary *photos;
@property NSMutableArray *orderedAnnotations;
@property float eta;
@property CLLocationDistance totalDistance;

@property BOOL didSetupViews;
@property BOOL isEditingTitle;

@end

@implementation BuildTourDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {

    self.titleTextField.text = self.tour.title ? : @"New Tour";
    self.tour.title = self.titleTextField.text;

    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];

    if (!self.didSetupViews) {
        [self setupViews];
    }

    [self updateViews];
    [self loadStops];
}

- (void)loadStops {

    PFQuery *query = [Stop query];
    [query whereKey:@"tour" equalTo:self.tour];
    [query orderByAscending:@"orderIndex"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *stops, NSError *error) {

        // dont' allow stops without locations to show up
        NSMutableArray *mutableArray = [NSMutableArray new];
        for (Stop *stop in stops) {
            if (stop.location != nil) {
                [mutableArray addObject:stop];
            }
        }
        self.stops = [mutableArray copy];
        [self loadStopsOnMap];
        [self loadPhotos];
    }];
}

- (void)loadPhotos {

    self.photos = [NSMutableDictionary new];

    for (Stop *stop in self.stops) {

        self.photos[stop.objectId] = [NSMutableArray new];
    }

    PFQuery *query = [Photo query];
    [query whereKey:@"tour" equalTo:self.tour];
    [query orderByAscending:@"order"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *photos, NSError *error) {

        // CHANGE THIS TO PRESET COVER PHOTO INSTEAD OF FIRST PHOTO OF FIRST STOP
        Photo *firstPhoto = photos.firstObject;
        self.coverPhotoImageView.file = firstPhoto.image;
        [self.coverPhotoImageView loadInBackground];

        for (Photo *photo in photos) {

            [self.photos[photo.stop.objectId] addObject:photo];
        }
       // NSLog(@"self.stops has %lu items. self.photos has %lu items. reloading collectionview data.", self.stops.count, self.photos.count);
        [self.photosCollectionView reloadData];
    }];
}

- (void)setupViews {

    [self setupCollectionView];

    CGFloat labelMarginX = 8;
    CGFloat labelMarginY = 8;
    CGFloat labelWidth = self.view.bounds.size.width / 2 - labelMarginX;
    CGFloat labelHeight = 20;

    self.totalDistanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelMarginX, labelMarginY, labelWidth, labelHeight)];
    self.estimatedTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelMarginX, labelHeight + labelMarginY, labelWidth, labelHeight)];
    self.distanceFromCurrentLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth + labelMarginX , labelMarginY, labelWidth, labelHeight)];
    self.ratingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth + labelMarginX, labelHeight + labelMarginY, labelWidth, labelHeight)];

    NSArray *labels = @[self.totalDistanceLabel, self.estimatedTimeLabel, self.distanceFromCurrentLocationLabel, self.ratingsLabel];

    for (UILabel *label in labels) {
        [label setFont:[UIFont systemFontOfSize:12]];
        //[label setTextColor:[UIColor whiteColor]];
    }

    CGFloat summaryWidth = self.view.bounds.size.width;
    CGFloat summaryHeight = self.tourDetailView.layer.bounds.size.height - (labelHeight*2 + labelMarginY);

    self.summaryTextView = [[SummaryTextView alloc] initWithFrame:CGRectMake(0, labelHeight*2 + labelMarginY, summaryWidth, summaryHeight)];
    //self.summaryTextView.text = @"Really super long tour description goes here.self.tourDetailView.layer.bounds.size.width";
    self.summaryTextView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    self.summaryTextView.delegate = self;

    [self.tourDetailView addSubview:self.totalDistanceLabel];
    [self.tourDetailView addSubview:self.estimatedTimeLabel];
    [self.tourDetailView addSubview:self.distanceFromCurrentLocationLabel];
    [self.tourDetailView addSubview:self.ratingsLabel];
    [self.tourDetailView addSubview:self.summaryTextView];

    self.tourDetailView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.7];

    [self setupEditStopsButton];

    self.titleTextField.layer.cornerRadius = 5.0;
    self.titleTextField.layer.borderColor = [UIColor clearColor].CGColor;
    self.titleTextField.layer.borderWidth = 0.0;
    [self.titleTextField setBackgroundColor:[UIColor clearColor]];

    self.didSetupViews = YES;
}

-(void)setupEditStopsButton {

    CGFloat editStopsButtonWidth = self.view.layer.bounds.size.width / 6;
    //NSLog(@"%f, %f", CGRectGetMinY(self.mapView.frame), CGRectGetMaxY(self.mapView.frame));
    self.editStopsButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.layer.bounds.size.width - editStopsButtonWidth, self.mapView.bounds.origin.y, editStopsButtonWidth, self.mapView.layer.bounds.size.height)];
    [self.editStopsButton setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:.5]];
    self.editStopsButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.editStopsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.editStopsButton setTitle:@"Add\n/Edit\nStops" forState:UIControlStateNormal];

    [self.editStopsButton addTarget:self action:@selector(performEditStopsSegue:) forControlEvents:UIControlEventTouchUpInside];

    [self.mapView addSubview:self.editStopsButton];

}

-(void)updateViews {

    self.totalDistanceLabel.text = self.tour.totalDistance ? [NSString stringWithFormat:@"Estimated Distance: %.2g", self.tour.totalDistance] : @"Estimated Distance:";
    self.estimatedTimeLabel.text = self.tour.estimatedTime ? [NSString stringWithFormat:@"Estimated Time: %.2g", self.tour.estimatedTime] : @"Estimated Time:";
    self.distanceFromCurrentLocationLabel.text = @"From Current Location: N/A";
    self.ratingsLabel.text = self.tour.averageRating ? [NSString stringWithFormat:@"Average Rating: %g", self.tour.averageRating] : @"Average Rating: N/A";
    self.summaryTextView.text = self.tour.summary ? : @"Write a brief description of the tour here.";
}

- (void)setupCollectionView {

    [self.photosCollectionView registerClass:[TourPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"PhotoCell"];

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];

    CGFloat cellWidth = self.photosCollectionView.layer.bounds.size.height;
    flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth);
    //NSLog(@"Cell width is %f", cellWidth);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 30.0);
    flowLayout.minimumLineSpacing = 1.0f;
    flowLayout.minimumInteritemSpacing = 1.0f;

    [self.photosCollectionView setCollectionViewLayout:flowLayout];

    self.photosCollectionView.layer.borderColor = [UIColor blackColor].CGColor;
    self.photosCollectionView.layer.borderWidth = 2.0f;
}

- (void)performEditStopsSegue:(UIButton *)sender {

    [self performSegueWithIdentifier:@"editStops" sender:self];
}

- (IBAction)onSaveButtonPressed:(UIBarButtonItem *)sender {

    self.navigationItem.leftBarButtonItem.enabled = NO;

    [self.tour saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"editStops"]) {

        BuildTourStopsViewController *destinationVC = (BuildTourStopsViewController *)[segue.destinationViewController topViewController];
        destinationVC.tour = self.tour;
    }
}


#pragma mark - UICollectionView dataSource/delegate methods

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    TourPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];

    Stop *stop = self.stops[indexPath.section];
    Photo *photo = self.photos[stop.objectId][indexPath.row];


    UIColor *sectionColor1 = [UIColor colorWithRed:19/255.0 green:157/255.0 blue:172/255.0 alpha:1.0];
    UIColor *sectionColor2 = [UIColor colorWithRed:177/255.0 green:243/255.0 blue:250/255.0 alpha:1.0];
    //NSLog(@"adding photo for stop %@", stop.title);
    cell.backgroundColor = indexPath.section % 2 ? sectionColor1 : sectionColor2;

    cell.imageView.file = photo.image;
    [cell.imageView loadInBackground];

    return cell;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    Stop *stop = self.stops[section];
    return [self.photos[stop.objectId] count];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.stops.count;
}

#pragma mark - MapKit methods

- (void)loadStopsOnMap {

    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    self.orderedAnnotations = [NSMutableArray new];

    for (Stop *stop in self.stops) {

        StopPointAnnotation *stopPointAnnotation = [[StopPointAnnotation alloc] initWithStop:stop];
        [self.mapView addAnnotation:stopPointAnnotation];
        [self.orderedAnnotations addObject:stopPointAnnotation];
    }
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];

    if (self.stops.count > 1) {
        [self generatePolylineForDirectionsFromIndex:0 toIndex:1];
        NSLog(@"Heeeeey");
        [self getEtaFromIndex:0 toIndex:1];
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];

    pin.userInteractionEnabled = YES;
    pin.canShowCallout = YES;

    return pin;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {

    StopPointAnnotation *annotation = view.annotation;
    Stop *stop = annotation.stop;

    //NSLog(@"%@", stop.title);

    if ([self.photos[stop.objectId] count] > 0) {

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:[self.stops indexOfObject:stop]];
        //NSLog(@"%@", indexPath);
        [self.photosCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
        // self.stopTitle.text = stop.title;
}

-(void)renderPolylineForRoute:(MKRoute *)route {

    MKPolyline *polyline = [route polyline];
    [self.mapView addOverlay:polyline];
    [self.mapView setNeedsDisplay];
}

//-(void)generatePolylineForDirectionsBetweenStops:(MKMapItem *)mapItem {
//
//    MKDirectionsRequest *request = [MKDirectionsRequest new];
//
//    request.source = [MKMapItem mapItemForCurrentLocation];
//    request.destination = mapItem;
//    //NSLog(@"%@", request.destination.description);
//
//    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
//
//    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
//
//        NSArray *routes = response.routes;
//        MKRoute *route = routes.firstObject;
//        //[self.mapView setVisibleMapRect:polyline.boundingMapRect];
////        for (MKRouteStep *step in route.steps) {
////            [self.directions addObject:step];
////
////        }
////        [self.tableView reloadData];
//    }];
//}

-(void)generatePolylineForDirectionsFromIndex:(int)sourceIndex toIndex:(int)destinationIndex{

    MKDirectionsRequest *request = [MKDirectionsRequest new];

    MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:[self.orderedAnnotations[sourceIndex] coordinate] addressDictionary:nil];
    MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:[self.orderedAnnotations[destinationIndex] coordinate] addressDictionary:nil];
    request.source = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
    request.destination = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];

    //request.transportType = MKDirectionsTransportTypeWalking;

    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];

    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {

        NSArray *routes = response.routes;
        MKRoute *route = routes.firstObject;

        MKPolyline *polyline = [route polyline];
        [self.mapView addOverlay:polyline];
        [self.mapView setNeedsDisplay];

        self.totalDistance += route.distance;
        if (destinationIndex < self.stops.count - 1) {
            [self generatePolylineForDirectionsFromIndex:destinationIndex toIndex:destinationIndex + 1];
        }
        else {
            float distanceInMiles = self.totalDistance/1609.34;
            self.totalDistanceLabel.text = [NSString stringWithFormat:@"Total Distance: %.2g miles", distanceInMiles];
            self.tour.totalDistance = distanceInMiles;
        }
    }];
}

-(void)getEtaFromIndex:(int)sourceIndex toIndex:(int)destinationIndex{

    MKDirectionsRequest *request = [MKDirectionsRequest new];

    MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:[self.orderedAnnotations[sourceIndex] coordinate] addressDictionary:nil];
    MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:[self.orderedAnnotations[destinationIndex] coordinate] addressDictionary:nil];
    request.source = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
    request.destination = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];

   // request.transportType = MKDirectionsTransportTypeDriving;
    NSLog(@"hello");
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];

    [directions calculateETAWithCompletionHandler:^(MKETAResponse *response, NSError *error) {

        self.eta += response.expectedTravelTime;
        NSLog(@"%f", self.eta);
        if (destinationIndex < self.stops.count - 1) {
            self.eta += 50;
            [self getEtaFromIndex:destinationIndex toIndex:destinationIndex + 1];
        }
        else {
            self.eta = floor(self.eta/60);
            NSLog(@"%f", self.eta);
            self.estimatedTimeLabel.text = [NSString stringWithFormat:@"Estimated Time: %g min", self.eta];
            self.tour.estimatedTime = self.eta;
        }
    }];
}


//-(void)getDirectionsTo:(MKMapItem *)mapItem {
//
//    MKDirectionsRequest *request = [MKDirectionsRequest new];
//
//    request.source = [MKMapItem mapItemForCurrentLocation];
//    request.destination = mapItem;
//    //NSLog(@"%@", request.destination.description);
//
//    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
//
//    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
//        NSArray *routes = response.routes;
//        MKRoute *route = routes.firstObject;
//
//        MKPolyline *polyline = [route polyline];
//        // NSLog(@"%lu", polyline.pointCount);
//        [self.mapView addOverlay:polyline];
//        //[self.mapView setVisibleMapRect:polyline.boundingMapRect];
//
//        [self.mapView setNeedsDisplay];
//
//        for (MKRouteStep *step in route.steps) {
//            [self.directions addObject:step];
//
//        }
//        [self.tableView reloadData];
//    }];
//}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];

    polylineRenderer.strokeColor = [UIColor blueColor];
    polylineRenderer.lineWidth = 4;
    
    return polylineRenderer;
}

#pragma mark - UITextField Delegate methods

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    self.isEditingTitle = YES;
    [self toggleTextFieldAppearance];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    //[self.view endEditing:YES];
    self.isEditingTitle = NO;
    [self toggleTextFieldAppearance];
    self.tour.title = self.titleTextField.text;
}

-(void)textFieldDidChange:(UITextField *)textField {
    self.tour.title = self.titleTextField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)toggleTextFieldAppearance {

    if (self.isEditingTitle) {
        [self.titleTextField setBackgroundColor:[UIColor whiteColor]];
        self.titleTextField.layer.borderWidth = 1.0;
    }
    else {
        [self.titleTextField setBackgroundColor:[UIColor clearColor]];
        self.titleTextField.layer.borderWidth = 0;
    }
}

#pragma mark - SummaryTextView Delegate methods

-(void)textViewDidChange:(UITextView *)textView {
    self.tour.summary = textView.text;
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
    [self.titleTextField resignFirstResponder];
}
//-(BOOL)textViewShouldEndEditing:(UITextView *)textView {
//
//    return YES;
//}
@end




