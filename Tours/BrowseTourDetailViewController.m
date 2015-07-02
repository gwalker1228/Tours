 //
//  BrowseTourDetailViewController.m
//  Tours
//
//  Created by Gretchen Walker on 6/25/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BrowseTourDetailViewController.h"
#import "TourPhotoCollectionViewCell.h"
#import "ReviewViewController.h"
#import "BrowseTourPreviewViewController.h"
#import "StopPointAnnotation.h"
#import "DesignableTransparentButton.h"
#import "SummaryTextView.h"
#import "Tour.h"
#import "Stop.h"
#import "Photo.h"
#import "Review.h"
#import "PhotoPopup.h"
#import "RateView.h"
#import <MapKit/MapKit.h>
#import <ParseUI/ParseUI.h>

@interface BrowseTourDetailViewController () <MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, SummaryTextViewDelegate, CLLocationManagerDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet PFImageView *coverPhotoImageView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
//@property (weak, nonatomic) IBOutlet UILabel *stopTitle;
@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;
@property (weak, nonatomic) IBOutlet UIView *tourDetailView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tourDetailViewHeightConstraint;
@property (weak, nonatomic) IBOutlet DesignableTransparentButton *reviewsButton;

@property UILabel *totalDistanceLabel;
@property UILabel *estimatedTimeLabel;
@property UILabel *distanceFromCurrentLocationLabel;
@property UILabel *ratingsLabel;
@property RateView *rateView;
@property SummaryTextView *summaryTextView;
@property UIButton *moreButton;
@property UIButton *expandButton;

@property NSArray *stops;
@property NSMutableDictionary *photos;
@property NSMutableArray *orderedAnnotations;
@property float eta;

@property CLLocationManager *locationManager;
@property double distanceFromCurrentLocation;
@property CLLocationDistance totalDistance;

@property BOOL didSetupViews;
@property BOOL didFindCurrentLocation;
@property BOOL didCalculateDistanceFromCurrentLocation;
@property BOOL didLoadStops;

@property BOOL userSelectedAnnotation;
@property BOOL isScrolling;

@end

@implementation BrowseTourDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
//    tapRecognizer.cancelsTouchesInView = NO;
//    [self.view addGestureRecognizer:tapRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {

    self.title = self.tour.title;
    self.summaryTextView.editable = NO;
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];

//    [self.reviewsButton setAlpha:.9];

    self.reviewsButton.layer.backgroundColor = [[UIColor colorWithCGColor:self.reviewsButton.layer.backgroundColor] colorWithAlphaComponent:.9].CGColor;

    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    [self.locationManager requestWhenInUseAuthorization];

    if (!self.didSetupViews) {
        [self setupViews];
        [self updateViews];
        [self loadStops];
        [self loadRatings];
    }
}

- (void)loadStops {

    PFQuery *query = [Stop query];
    [query whereKey:@"tour" equalTo:self.tour];
    [query orderByAscending:@"orderIndex"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *stops, NSError *error) {
        self.stops = stops;
        self.didLoadStops = YES;

        if (self.didFindCurrentLocation && !self.didCalculateDistanceFromCurrentLocation) {
            [self calculateDistanceFromCurrentLocation];
        }
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
        [self.photosCollectionView reloadData];
    }];
}

- (void)loadRatings {

    PFQuery *query = [Review query];
    [query whereKey:@"tour" equalTo:self.tour];

    [query findObjectsInBackgroundWithBlock:^(NSArray *reviews, NSError *error) {

        if (!error) {
            [self.reviewsButton setTitle:[NSString stringWithFormat:@"Reviews (%lu)", reviews.count] forState:UIControlStateNormal];
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
    self.ratingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth + labelMarginX, labelHeight + labelMarginY, ratingsLabelWidth, labelHeight)];
    self.rateView = [[RateView alloc] initWithFrame:CGRectMake(self.ratingsLabel.frame.origin.x + ratingsLabelWidth, labelHeight + labelMarginY, labelWidth - ratingsLabelWidth, labelHeight)];

    NSArray *labels = @[self.totalDistanceLabel, self.estimatedTimeLabel, self.distanceFromCurrentLocationLabel, self.ratingsLabel];

    UIColor *textColor = [UIColor colorWithRed:25/255.0f green:52/255.0f blue:65/255.0f alpha:1.0];

    for (UILabel *label in labels) {
        [label setFont:[UIFont fontWithName:@"AvenirNextCondensed-Regular" size:16]];
        [label setTextColor:textColor];
        //[label setFont:[UIFont systemFontOfSize:12]];
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

    self.summaryTextView.font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:17];
    [self.summaryTextView setTextColor:textColor];

    self.tourDetailView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.7];

    [self setupExpandButton];

    self.didSetupViews = YES;
}

-(void)setupExpandButton {

    CGFloat expandButtonWidth = self.view.layer.bounds.size.width / 6;
    self.expandButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.layer.bounds.size.width - expandButtonWidth, self.mapView.bounds.origin.y, expandButtonWidth, self.mapView.layer.bounds.size.height)];
    [self.expandButton setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:.5]];
    self.expandButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.expandButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.expandButton setTitle:@"E\nx\np\na\nn\nd" forState:UIControlStateNormal];

    [self.expandButton addTarget:self action:@selector(performExpandSegue:) forControlEvents:UIControlEventTouchUpInside];

    [self.mapView addSubview:self.expandButton];

}

- (IBAction)onReviewsButtonPressed:(UIButton *)sender {

}

-(void)updateViews {

    self.totalDistanceLabel.text = self.tour.totalDistance ? [NSString stringWithFormat:@"Total Distance: %.1f miles", self.tour.totalDistance] : @"Total Distance:";
    self.estimatedTimeLabel.text = self.tour.estimatedTime ? [NSString stringWithFormat:@"Est. Time: %@", getTimeStringFromETAInMinutes(self.tour.estimatedTime)] : @"Est. Time:";
    self.distanceFromCurrentLocationLabel.text = [NSString stringWithFormat:@""];
    self.ratingsLabel.text = @"Rating: ";
    self.rateView.rating = self.tour.averageRating;

    if (self.tour.averageRating) {
        [self.tourDetailView addSubview:self.rateView];
    }

    self.summaryTextView.text = self.tour.summary ? : @"";
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


- (void)performExpandSegue:(UIButton *)sender {

    [self performSegueWithIdentifier:@"previewTour" sender:self];
}

- (IBAction)onSaveButtonPressed:(UIBarButtonItem *)sender {

    self.navigationItem.leftBarButtonItem.enabled = NO;

    [self.tour saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"previewTour"]) {

        BrowseTourPreviewViewController *destinationVC = segue.destinationViewController;
        destinationVC.tour = self.tour;
    } else if ([segue.identifier isEqualToString:@"reviews"]) {


        ReviewViewController *destinationVC =  (ReviewViewController *)[segue.destinationViewController topViewController];
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


- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

    if (!self.userSelectedAnnotation && self.isScrolling) {
        int scrolledToIndexPath = (int)indexPath.section;
        [self.mapView selectAnnotation:self.orderedAnnotations[scrolledToIndexPath] animated:NO];
    }
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    Stop *stop = self.stops[section];
    return [self.photos[stop.objectId] count];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.stops.count;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    //TourPhotoCollectionViewCell *cell = [[TourPhotoCollectionViewCell alloc] init];
    TourPhotoCollectionViewCell *cell = (TourPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

    Stop *stop = self.stops[indexPath.section];
    Photo *photo = self.photos[stop.objectId][indexPath.row];

    [PhotoPopup popupWithImage:cell.imageView.image photo:photo inView:self.view editable:NO delegate:nil];
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
        //[self getEtaFromIndex:0 toIndex:1];
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

        if (!error) {
            NSArray *routes = response.routes;
            MKRoute *route = routes.firstObject;

            MKPolyline *polyline = [route polyline];
            [self.mapView addOverlay:polyline];
            [self.mapView setNeedsDisplay];

            self.totalDistance += route.distance;
        }
        
        if (destinationIndex < self.stops.count - 1) {
            [self generatePolylineForDirectionsFromIndex:destinationIndex toIndex:destinationIndex + 1];
        }
        else {
            self.totalDistanceLabel.text = [NSString stringWithFormat:@"Total Distance: %.1f miles", self.totalDistance/1609.34];
        }

    }];
}

-(void)getEtaFromIndex:(int)sourceIndex toIndex:(int)destinationIndex{

    MKDirectionsRequest *request = [MKDirectionsRequest new];

    MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:[self.orderedAnnotations[sourceIndex] coordinate] addressDictionary:nil];
    MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:[self.orderedAnnotations[destinationIndex] coordinate] addressDictionary:nil];
    request.source = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
    request.destination = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];

    request.transportType = MKDirectionsTransportTypeWalking;

    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];

    [directions calculateETAWithCompletionHandler:^(MKETAResponse *response, NSError *error) {

        self.eta += response.expectedTravelTime;

        if (destinationIndex < self.stops.count - 1) {
            self.eta += 50*60;
            [self getEtaFromIndex:destinationIndex toIndex:destinationIndex + 1];
        }
        else {
            self.eta = floor(self.eta/60);
            self.estimatedTimeLabel.text = [NSString stringWithFormat:@"Estimated Time: %g min", self.eta];
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


#pragma mark - CLLocationManager

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    for (CLLocation *location in locations) {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {

            [self.locationManager stopUpdatingLocation];
            self.didFindCurrentLocation = YES;

            if (self.didLoadStops && !self.didCalculateDistanceFromCurrentLocation) {
                [self calculateDistanceFromCurrentLocation];
            }
            break;
        }
    }
}


-(void)calculateDistanceFromCurrentLocation {

    self.didCalculateDistanceFromCurrentLocation = YES;

    Stop *firstStop = [self.stops firstObject];
    [firstStop fetchIfNeeded];

    self.distanceFromCurrentLocation = [firstStop.location distanceInMilesTo:[PFGeoPoint geoPointWithLocation:[self.locationManager location]]];

    self.distanceFromCurrentLocationLabel.text = [NSString stringWithFormat:@"%.1f miles away", self.distanceFromCurrentLocation];
}


@end



