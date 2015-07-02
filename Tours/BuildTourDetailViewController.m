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
#import "BuildStopImagePickerViewController.h"
#import "StopPointAnnotation.h"
#import "SummaryTextView.h"
#import "Tour.h"
#import "Stop.h"
#import "Photo.h"
#import "PhotoPopup.h"
#import "RateView.h"
#import <MapKit/MapKit.h>
#import <ParseUI/ParseUI.h>

@interface BuildTourDetailViewController () <MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, SummaryTextViewDelegate, PhotoPopupDelegate>

@property (weak, nonatomic) IBOutlet PFImageView *coverPhotoImageView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
//@property (weak, nonatomic) IBOutlet UILabel *stopTitle;
@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;
@property (weak, nonatomic) IBOutlet UIView *tourDetailView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tourDetailViewHeightConstraint;
@property PhotoPopup *photoPopup;

@property UILabel *totalDistanceLabel;
@property UILabel *estimatedTimeLabel;
@property UILabel *distanceFromCurrentLocationLabel;
@property UILabel *ratingsLabel;
@property RateView *rateView;
@property UITextView *summaryTextView;
@property UIButton *moreButton;
@property UIButton *editStopsButton;

@property NSArray *stops;
@property NSMutableDictionary *photos;
@property NSMutableArray *orderedAnnotations;
@property float eta;
@property CLLocationDistance totalDistance;

@property BOOL didSetupViews;
@property BOOL isEditingTitle;

@property BOOL isScrolling;
@property BOOL userSelectedAnnotation;

@end

@implementation BuildTourDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];


    self.titleTextField.clearButtonMode = UITextFieldViewModeAlways;

}

- (void)viewWillAppear:(BOOL)animated {

    self.titleTextField.text = self.tour.title ? : @"New Tour";
    self.tour.title = self.titleTextField.text;

    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];

    if (!self.didSetupViews) {
        [self setupViews];
    }

    if (self.photoPopup) {
        [self.photoPopup reloadViews];
    }

    [self updateViews];
    [self loadStops];

    self.titleTextField.delegate = self;
    [self.titleTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    self.titleTextField.rightView.frame = CGRectMake(self.titleTextField.rightView.frame.origin.x - 30, 0, 15, 15);
    self.titleTextField.rightView = clearButton;

    //clearButton.frame = [self.titleTextField clearButtonRectForBounds:self.titleTextField.rightView.frame];
    //clearButton.frame = CGRectMake(-50, 0, 10, 10);
    [clearButton setImage:[UIImage imageNamed:@"buttonForClear"] forState:UIControlStateNormal];
    self.titleTextField.rightViewMode = UITextFieldViewModeAlways;
    [clearButton addTarget:self action:@selector(clearText) forControlEvents:UIControlEventTouchUpInside];
}

- (void)clearText {
    self.titleTextField.text = @"";
    [self.titleTextField becomeFirstResponder];
}


- (void)loadStops {

    PFQuery *query = [Stop query];
    [query whereKey:@"tour" equalTo:self.tour];
    [query orderByAscending:@"orderIndex"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *stops, NSError *error) {

        // don't allow stops without locations to show up
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

        if (photos.count == 0) {
            self.coverPhotoImageView.image = [UIImage imageNamed:@"placeholderCoverPhoto"];
        }
        else {
            // CHANGE THIS TO PRESET COVER PHOTO INSTEAD OF FIRST PHOTO OF FIRST STOP
            Photo *firstPhoto = photos.firstObject;
            self.coverPhotoImageView.file = firstPhoto.image;
            [self.coverPhotoImageView loadInBackground];

            for (Photo *photo in photos) {

                [self.photos[photo.stop.objectId] addObject:photo];
            }
            [self.photosCollectionView reloadData];
        }
    }];
}

- (void)setupViews {

    [self setupCollectionView];

    CGFloat labelMarginX = 8;
    CGFloat labelMarginY = 8;
    CGFloat labelWidth = self.view.bounds.size.width / 2 - labelMarginX;
    CGFloat labelHeight = 20;

    CGFloat ratingsLabelWidth = labelWidth / 3;

    self.totalDistanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelMarginX, labelMarginY, labelWidth, labelHeight)];
    self.estimatedTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelMarginX, labelHeight + labelMarginY, labelWidth, labelHeight)];
    self.distanceFromCurrentLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth + labelMarginX , labelMarginY, labelWidth, labelHeight)];
    self.ratingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth + labelMarginX, labelHeight + labelMarginY, labelWidth, labelHeight)];
    self.rateView = [[RateView alloc] initWithFrame:CGRectMake(self.ratingsLabel.frame.origin.x + ratingsLabelWidth, labelHeight + labelMarginY, labelWidth - ratingsLabelWidth, labelHeight)];

    NSArray *labels = @[self.totalDistanceLabel, self.estimatedTimeLabel, self.distanceFromCurrentLocationLabel, self.ratingsLabel];

    for (UILabel *label in labels) {
        [label setFont:[UIFont fontWithName:@"AvenirNextCondensed-Regular" size:16]];
        //[label setFont:[UIFont systemFontOfSize:12]];
        //[label setTextColor:[UIColor whiteColor]];
    }

    CGFloat summaryWidth = self.view.bounds.size.width;
    CGFloat summaryHeight = self.tourDetailView.layer.bounds.size.height - (labelHeight*2 + labelMarginY);


    self.summaryTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, labelHeight*2 + labelMarginY, summaryWidth, summaryHeight)];
    //self.summaryTextView.text = @"Really super long tour description goes here.self.tourDetailView.layer.bounds.size.width";
    self.summaryTextView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    self.summaryTextView.delegate = self;
    [self.summaryTextView setFont:[UIFont fontWithName:@"AvenirNextCondensed-Regular" size:18]];

    [self.tourDetailView addSubview:self.totalDistanceLabel];
    [self.tourDetailView addSubview:self.estimatedTimeLabel];
    [self.tourDetailView addSubview:self.distanceFromCurrentLocationLabel];
    [self.tourDetailView addSubview:self.ratingsLabel];
    [self.tourDetailView addSubview:self.summaryTextView];

    self.tourDetailView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.7];

    [self setupEditStopsButton];

    self.titleTextField.layer.cornerRadius = 5.0;
    self.titleTextField.layer.borderColor = [UIColor whiteColor].CGColor;
    self.titleTextField.layer.borderWidth = 0.5;
    [self.titleTextField setBackgroundColor:[UIColor clearColor]];
    [self.titleTextField setTextColor:[UIColor whiteColor]];
    //[self.titleTextField setFont:[UIFont fontWithName:@"AvenirNextCondensed=Medium" size:18]];

    self.didSetupViews = YES;
}

-(void)setupEditStopsButton {

    CGFloat editStopsButtonWidth = self.view.layer.bounds.size.width / 6;
    self.editStopsButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.layer.bounds.size.width - editStopsButtonWidth, self.mapView.bounds.origin.y, editStopsButtonWidth, self.mapView.layer.bounds.size.height)];
    [self.editStopsButton setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:.5]];
    self.editStopsButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.editStopsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.editStopsButton setTitle:@"Add\n/Edit\nStops" forState:UIControlStateNormal];

    [self.editStopsButton addTarget:self action:@selector(performEditStopsSegue:) forControlEvents:UIControlEventTouchUpInside];

    [self.mapView addSubview:self.editStopsButton];

}

-(void)updateViews {

    self.totalDistanceLabel.text = self.tour.totalDistance ? [NSString stringWithFormat:@"Total Distance: %.1f", self.tour.totalDistance] : @"Total Distance:";
    self.estimatedTimeLabel.text = self.tour.estimatedTime ? [NSString stringWithFormat:@"Est. Time: %@", getTimeStringFromETAInMinutes(self.tour.estimatedTime)] : @"Est. Time:";
    self.distanceFromCurrentLocationLabel.text = @"From Current Location: N/A";
    self.ratingsLabel.text = @"Rating: ";
    self.rateView.rating = self.tour.averageRating;

    if (self.tour.averageRating) {
        [self.tourDetailView addSubview:self.rateView];
    }

    self.summaryTextView.text = self.tour.summary ? : @"Write a brief description of the tour here.";
}

- (void)setupCollectionView {

    [self.photosCollectionView registerClass:[TourPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"PhotoCell"];

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];

    CGFloat cellWidth = self.photosCollectionView.layer.bounds.size.height;
    flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth);
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

    self.tour.title = self.titleTextField.text;
    self.tour.summary = self.summaryTextView.text;

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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

    self.isScrolling = YES;
    self.userSelectedAnnotation = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

    if (!decelerate) {
        self.userSelectedAnnotation = NO;
        self.isScrolling = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    self.userSelectedAnnotation = NO;
    self.isScrolling = NO;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    TourPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];

    Stop *stop = self.stops[indexPath.section];
    Photo *photo = self.photos[stop.objectId][indexPath.row];


    UIColor *sectionColor1 = [UIColor colorWithRed:19/255.0 green:157/255.0 blue:172/255.0 alpha:1.0];
    UIColor *sectionColor2 = [UIColor colorWithRed:177/255.0 green:243/255.0 blue:250/255.0 alpha:1.0];
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    TourPhotoCollectionViewCell *cell = (TourPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

    Stop *stop = self.stops[indexPath.section];
    Photo *photo = self.photos[stop.objectId][indexPath.row];

    [PhotoPopup popupWithImage:cell.imageView.image photo:photo inView:self.view editable:YES delegate:self];

}

#pragma mark - PhotoPopupDelegate

-(void)photoPopup:(PhotoPopup *)photoPopup editPhotoButtonPressed:(Photo *)photo {

    Stop* stop = photo.stop;
    [stop fetchIfNeeded];
    Tour *tour = photo.tour;
    [tour fetchIfNeeded];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BuildStopImagePickerViewController *buildStopImagePickerVC = [storyboard instantiateViewControllerWithIdentifier:@"BuildStopImagePickerVC"];

    buildStopImagePickerVC.photo = photo;
    buildStopImagePickerVC.stop = stop;
    buildStopImagePickerVC.tour = tour;

    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);

    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.parentViewController presentViewController:buildStopImagePickerVC animated:YES completion:nil];
    });
}

-(void)photoPopup:(PhotoPopup *)photoPopup viewDidAppear:(Photo *)photo {
    self.photoPopup = photoPopup;
}

-(void)photoPopup:(PhotoPopup *)photoPopup viewDidDisappear:(Photo *)photo {
    self.photoPopup = nil;
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

    if ([self.photos[stop.objectId] count] > 0) {

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:[self.stops indexOfObject:stop]];


        if (!self.isScrolling) {

            self.userSelectedAnnotation = YES;

            [self.photosCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
        }
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
            self.totalDistanceLabel.text = [NSString stringWithFormat:@"Total Distance: %.1f miles", distanceInMiles];
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
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];

    [directions calculateETAWithCompletionHandler:^(MKETAResponse *response, NSError *error) {

        self.eta += response.expectedTravelTime;
        self.eta += 50*60;

        if (destinationIndex < self.stops.count - 1) {
            [self getEtaFromIndex:destinationIndex toIndex:destinationIndex + 1];
        }
        else {
            self.eta = floor(self.eta/60);

            self.estimatedTimeLabel.text = [NSString stringWithFormat:@"Est. Time: %@", getTimeStringFromETAInMinutes(self.eta)];
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
//
//    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
//
//    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
//        NSArray *routes = response.routes;
//        MKRoute *route = routes.firstObject;
//
//        MKPolyline *polyline = [route polyline];
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

//-(void)textFieldDidBeginEditing:(UITextField *)textField {
//    self.isEditingTitle = YES;
//    [self toggleTextFieldAppearance];
//}
//
//-(void)textFieldDidEndEditing:(UITextField *)textField {
//    //[self.view endEditing:YES];
//    self.isEditingTitle = NO;
//    [self toggleTextFieldAppearance];
//    self.tour.title = self.titleTextField.text;
//}

-(void)textFieldDidChange:(UITextField *)textField {
    self.tour.title = self.titleTextField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)toggleTextFieldAppearance {

    if (self.isEditingTitle) {
//        [self.titleTextField setBackgroundColor:[UIColor colorWithRed:25/255.0 green:52/255.0 blue:65/255.0 alpha:1.0];
        self.titleTextField.layer.borderColor = [UIColor whiteColor].CGColor;
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




