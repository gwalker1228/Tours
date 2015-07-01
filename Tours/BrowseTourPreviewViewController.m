//
//  BrowseTourPreviewViewController.m
//  Tours
//
//  Created by Gretchen Walker on 6/25/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BrowseTourPreviewViewController.h"
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "StopPointAnnotation.h"
#import "StopDetailMKPinAnnotationView.h"
#import "StopDetailMKPinAnnotationView.h"
#import "BrowseStopDetailViewController.h"
#import "BuildTourStopsTableViewCell.h"
#import "Photo.h"
#import "Stop.h"
#import "Tour.h"
#import "PhotoPopup.h"
#import "IndexedPhotoCollectionView.h"
#import "IndexedPhotoCollectionViewCell.h"
#import "InteractPinAnnotationView.h"
#import <ParseUI/ParseUI.h>

static NSString *polylineBetweenStopAndCurrentLocationID = @"polylineBetweenStopAndCurrentLocationID";
static NSString *polylineBetweenStopsID = @"polylineBetweenStopsID";


@interface BrowseTourPreviewViewController () <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property UIButton *getDirectionsButton;
@property UITableView *directionsTableView;

@property NSArray *photosForSelectedStop;
@property NSMutableArray *stopAnnotations;
@property NSMutableDictionary *directionsFromCurrentLocation;
@property NSMutableDictionary *polylinesForDirectionsFromCurrentLocation;
@property NSArray *photos;
@property NSArray *stops;
@property NSMutableDictionary *stopPhotos;
@property StopDetailMKPinAnnotationView *currentPinAnnotationView;
@property MKAnnotationView *selectedAnnotationView;
@property MKPolyline *directionsPolyline;
//@property PhotoPopup *photoPopup;

@property CLLocationManager *locationManager;

@property BOOL foundPhotosForStop;
@property BOOL removeViewAfterNextSelection;
@property BOOL showingDirections;

@end

@implementation BrowseTourPreviewViewController

-(void)viewDidLoad {

    [super viewDidLoad];

    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeHybrid;
    self.stopAnnotations = [NSMutableArray new];

    self.directionsFromCurrentLocation = [NSMutableDictionary new];
    self.polylinesForDirectionsFromCurrentLocation = [NSMutableDictionary new];

    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    [self.locationManager requestWhenInUseAuthorization];

    //self.title = self.tour.title;

    self.mapView.showsUserLocation = YES;

    [self setupGetDirectionsButton];
    [self setupDirectionsTableView];
}

-(void)viewWillAppear:(BOOL)animated {

    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    [self loadStops];
    //[self.tableView reloadData];
    self.foundPhotosForStop = NO;
    self.removeViewAfterNextSelection = NO;
}


- (IBAction)onSegmentedControlPressed:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 1) {

        [UIView animateWithDuration:1.0 animations:^{
            self.mapView.alpha = 0.0;

            [UIView animateWithDuration:0.0 animations:^{
                [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.tableView cache:YES];

            } completion:^(BOOL finished) {
                [self.view bringSubviewToFront:self.tableView];
            }];
        } completion:^(BOOL finished) {

            self.mapView.alpha = 1.0;
        }];
    }
    else {
        [UIView animateWithDuration:1.0 animations:^{
            self.tableView.alpha = 0.0;

            [UIView animateWithDuration:0.0 animations:^{
                [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.mapView cache:YES];

            } completion:^(BOOL finished) {
                [self.view bringSubviewToFront:self.mapView];
                [self.view bringSubviewToFront:self.getDirectionsButton];
                [self.view bringSubviewToFront:self.directionsTableView];

            }];
        } completion:^(BOOL finished) {
            self.tableView.alpha = 1.0;
        }];
    }

}

-(void)setupGetDirectionsButton {

    CGFloat rightMargin = 8;
    //CGFloat bottomMargin = 8;

    CGFloat directionsButtonWidth = 150;
    CGFloat directionsButtonHeight = 50;
    CGFloat directionsButtonX = self.view.frame.size.width - directionsButtonWidth - rightMargin;
    CGFloat directionsButtonY = self.view.frame.size.height;

    UIColor *color1 = [UIColor colorWithRed:252/255.0f green:255/255.0f blue:245/255.0f alpha:1.0];
    UIColor *color3 = [UIColor colorWithRed:145/255.0f green:170/255.0f blue:157/255.0f alpha:1.0];

    self.getDirectionsButton = [[UIButton alloc] initWithFrame:CGRectMake(directionsButtonX, directionsButtonY, directionsButtonWidth, directionsButtonHeight)];

    [self.getDirectionsButton setTitle:@"Directions From Current Location" forState:UIControlStateNormal];

    self.getDirectionsButton.tintColor = color1;
    self.getDirectionsButton.backgroundColor = color3;
    self.getDirectionsButton.titleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:18];
    self.getDirectionsButton.layer.cornerRadius = 5;

    [self.getDirectionsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.getDirectionsButton.titleLabel.numberOfLines = 0;

    [self.getDirectionsButton addTarget:self action:@selector(onGetDirectionsButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.getDirectionsButton];

}

-(void)setupDirectionsTableView {

    CGFloat directionsTableViewWidth = self.view.frame.size.width;
    CGFloat directionsTableViewHeight = self.view.frame.size.height / 3;
    CGFloat directionsTableViewX = 0;
    CGFloat directionsTableViewY = self.view.frame.size.height + 50;

    self.directionsTableView = [[UITableView alloc] initWithFrame:CGRectMake(directionsTableViewX, directionsTableViewY, directionsTableViewWidth, directionsTableViewHeight)];

    self.directionsTableView.tag = 1;
    self.directionsTableView.delegate = self;
    self.directionsTableView.dataSource = self;
    self.directionsTableView.allowsSelection = NO;

    [self.view addSubview:self.directionsTableView];
}

-(void)setGetDirectionsButtonHidden:(BOOL)hidden {

    CGFloat bottomMargin = 8;

    CGRect newFrame = self.getDirectionsButton.frame;
    newFrame.origin.y = hidden ? self.view.frame.size.height + 20 : self.view.frame.size.height - self.getDirectionsButton.frame.size.height - bottomMargin;

    [UIView animateWithDuration:.5 delay:0.0 options:UIViewAnimationOptionTransitionCurlUp animations:^{

        self.getDirectionsButton.frame = newFrame;

    } completion:^(BOOL finished) {

    }];
}

-(void)onGetDirectionsButtonPressed {

    [self setGetDirectionsButtonHidden:YES];
    [self setDirectionsTableViewHidden:NO];
}

-(void)displayDirections {

    if (self.directionsPolyline) {
        [self.mapView removeOverlay:self.directionsPolyline];
        self.directionsPolyline = nil;
    }

    if (!self.showingDirections) {
        [self setDirectionsTableViewHidden:NO];
    }
    [self.directionsTableView reloadData];

    StopPointAnnotation *stopPointAnnotation = self.selectedAnnotationView.annotation;
    Stop *stop = stopPointAnnotation.stop;
    [stop fetchIfNeeded];

    if (self.directionsFromCurrentLocation[stop.objectId] && [self.directionsFromCurrentLocation[stop.objectId] count] > 0) {
        [self.directionsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }

    self.directionsPolyline = self.polylinesForDirectionsFromCurrentLocation[stop.objectId];

    if (self.directionsPolyline) {

        [self.mapView addOverlay:self.directionsPolyline];
        [self.mapView setNeedsDisplay];
    }
}

-(void)setDirectionsTableViewHidden:(BOOL)hidden {

    self.showingDirections = !hidden;

    if (!hidden) {
        [self displayDirections];
        //[self setGetDirectionsButtonHidden:YES];
    }
    else if (self.directionsPolyline) {
        [self.mapView removeOverlay:self.directionsPolyline];
        self.directionsPolyline = nil;
    }

    CGRect newFrame = self.directionsTableView.frame;
    newFrame.origin.y = hidden ? self.view.frame.size.height + 50 : self.view.frame.size.height - self.directionsTableView.frame.size.height;

    [UIView animateWithDuration:.5 delay:0.0 options:UIViewAnimationOptionTransitionCurlUp animations:^{

        self.directionsTableView.frame = newFrame;

    } completion:^(BOOL finished) {
        
    }];
}

-(void)loadStops {

    PFQuery *query = [Stop query];
    [query whereKey:@"tour" equalTo:self.tour];
    [query orderByAscending:@"index"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *stops, NSError *error){

        if (!error) {
            self.stops = stops;
            NSLog(@"%@ %@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.stops); // TO DELETE

            [self loadPhotos];
        } else {
            // error check
        }
    }];
}

-(void)loadPhotos {

    self.stopPhotos = [NSMutableDictionary new];

    for (Stop *stop in self.stops) {
        self.stopPhotos[stop.objectId] = [NSMutableArray new];
    }

    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"tour" equalTo:self.tour];
    [query findObjectsInBackgroundWithBlock:^(NSArray *photos, NSError *error) {

        self.photos = photos;

        for (Photo *photo in self.photos) {

            Stop *photoStop = photo.stop;
            [self.stopPhotos[photoStop.objectId] addObject:photo];
        }

        [self placeStopAnnotationsOnMap];
        [self.tableView reloadData];
    }];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    BrowseStopDetailViewController *destinationVC = segue.destinationViewController;

    if ([segue.identifier isEqualToString:@"browseStop"]) {

        destinationVC.stop = self.stops[[self.tableView indexPathForSelectedRow].row];
    }
}


#pragma mark - UITableViewDataSource & Delegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (tableView.tag == 1) {

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"directionsCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"directionsCell"];
        }

        StopPointAnnotation *stopPointAnnotation = self.selectedAnnotationView.annotation;
        Stop *stop = stopPointAnnotation.stop;
        [stop fetchIfNeeded];

        if (self.directionsFromCurrentLocation[stop.objectId] && [self.directionsFromCurrentLocation[stop.objectId] count] > 0) {
            NSMutableArray *directions = self.directionsFromCurrentLocation[stop.objectId];
            cell.textLabel.text = [NSString stringWithFormat:@"%lu. %@", indexPath.row + 1, directions[indexPath.row]];
        }
        else {
            cell.textLabel.text = @"Directions are unavailable for this location.";
        }
        return cell;
    }
    else {
        BuildTourStopsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BuildTourStopsTableViewCellIdentifier];

        if (cell == nil) {
            cell = [[BuildTourStopsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BuildTourStopsTableViewCellIdentifier size:CGSizeMake(self.tableView.bounds.size.width, tableCellHeight)];
        }

        [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];

        Stop *stop = self.stops[indexPath.row];

        cell.title = stop.title;
        cell.summary = stop.summary;
        
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return tableView.tag == 1 ? 44 : tableCellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (tableView.tag == 1) {

        if (self.selectedAnnotationView) {
            StopPointAnnotation *stopPointAnnotation = self.selectedAnnotationView.annotation;
            Stop *stop = stopPointAnnotation.stop;
            [stop fetchIfNeeded];

            if (self.directionsFromCurrentLocation[stop.objectId] && [self.directionsFromCurrentLocation[stop.objectId] count] > 0) {

                return [self.directionsFromCurrentLocation[stop.objectId] count];
            }
            return 1;
        }
        return 0;
    }
    return self.stops.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self performSegueWithIdentifier:@"browseStop" sender:self];
}

#pragma mark - MapView methods

-(void) placeStopAnnotationsOnMap {

    for (Stop *stop in self.stops) {

        StopPointAnnotation *stopAnnotation = [[StopPointAnnotation alloc] initWithStop:stop];

        [self.stopAnnotations addObject:stopAnnotation];
        [self.mapView addAnnotation:stopAnnotation];
    }
    [self.mapView showAnnotations:self.stopAnnotations animated:YES];

    if (self.stops.count > 1) {
        [self generatePolylineForDirectionsFromIndex:0 toIndex:1];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    if (annotation == mapView.userLocation) return nil;

    StopDetailMKPinAnnotationView *annotationView = [[StopDetailMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];

    CGRect stopViewFrame = CGRectMake(0, 0, 200, 150);
    [annotationView.leftCalloutAccessoryView sizeThatFits:stopViewFrame.size];

    annotationView.canShowCallout = YES;
    annotationView.enabled = YES;

    [self getDirectionsFromCurrentLocationToAnnotationView:annotationView];

    return annotationView;
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {

    if (view.annotation == mapView.userLocation) return;

    if ([(StopDetailMKPinAnnotationView *)view isEqual:self.selectedAnnotationView]) {

        [self.currentPinAnnotationView removeFromSuperview];
        self.selectedAnnotationView = nil;
        [self.mapView deselectAnnotation:view.annotation animated:NO];


        if (self.showingDirections) {
            [self setDirectionsTableViewHidden:YES];
        }
        else {
            [self setGetDirectionsButtonHidden:YES];
        }
    }
    else {
        if (self.currentPinAnnotationView) {
            [self.currentPinAnnotationView removeFromSuperview];
        }

        StopPointAnnotation *stopPointAnnotation = view.annotation;
        Stop *stop = stopPointAnnotation.stop;

        [self.mapView deselectAnnotation:stopPointAnnotation animated:NO];

        self.photosForSelectedStop = [self.stopPhotos objectForKey:stop.objectId];

        CGRect stopViewFrame = CGRectMake(0, 0, 200, 150);
        StopDetailMKPinAnnotationView *stopView = [[StopDetailMKPinAnnotationView alloc] initWithFrame:stopViewFrame];
        stopView.backgroundColor = [UIColor whiteColor];
        addSubview:stopView.center = CGPointMake(view.bounds.size.width*0.5f, -stopView.bounds.size.height*0.5f);

        [stopView setCollectionViewDataSourceDelegate:self indexPath:nil];
        stopView.titleLabel.text = stop.title;
        stopView.summaryLabel.text = stop.summary;

        self.currentPinAnnotationView = stopView;
        self.selectedAnnotationView = view;

        [view addSubview:stopView];

        if (self.showingDirections) {
            [self displayDirections];
        }
        else {
            [self setGetDirectionsButtonHidden:NO];
        }
    }
}

-(void)generatePolylineForDirectionsFromIndex:(int)sourceIndex toIndex:(int)destinationIndex{

    MKDirectionsRequest *request = [MKDirectionsRequest new];

    MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:[self.stopAnnotations[sourceIndex] coordinate] addressDictionary:nil];
    MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:[self.stopAnnotations[destinationIndex] coordinate] addressDictionary:nil];
    request.source = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
    request.destination = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];

    //request.transportType = MKDirectionsTransportTypeWalking;

    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];

    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {

        if (!error) {
            NSArray *routes = response.routes;
            MKRoute *route = routes.firstObject;


            MKPolyline *polyline = [route polyline];
            polyline.title = polylineBetweenStopsID;

            [self.mapView addOverlay:polyline];
            [self.mapView setNeedsDisplay];
        }
        
        if (destinationIndex < self.stops.count - 1) {
            [self generatePolylineForDirectionsFromIndex:destinationIndex toIndex:destinationIndex + 1];
        }

    }];
}

-(void)getDirectionsFromCurrentLocationToAnnotationView:(StopDetailMKPinAnnotationView *)view {

    if ([self.locationManager location]) {

        MKDirectionsRequest *request = [MKDirectionsRequest new];

        request.source = [MKMapItem mapItemForCurrentLocation];
        MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:[view.annotation coordinate] addressDictionary:nil];
        request.destination = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];

        //request.transportType = MKDirectionsTransportTypeWalking;

        MKDirections *directions = [[MKDirections alloc] initWithRequest:request];

        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {

            NSLog(@"calculating directions for view %@", view);
            if (!error) {
                NSArray *routes = response.routes;
                MKRoute *route = routes.firstObject;

                MKPolyline *polyline = [route polyline];
                polyline.title = polylineBetweenStopAndCurrentLocationID;

                self.directionsPolyline = polyline;

                NSMutableArray *directionsSteps = [NSMutableArray new];

                for (MKRouteStep *step in route.steps) {
                    [directionsSteps addObject:step.instructions];
                }

                NSLog(@"Directions for view are %@", directionsSteps);

                StopPointAnnotation *stopPointAnnotation = view.annotation;
                Stop *stop = stopPointAnnotation.stop;
                [stop fetchIfNeeded];

                self.directionsFromCurrentLocation[stop.objectId] = directionsSteps;
                self.polylinesForDirectionsFromCurrentLocation[stop.objectId] = polyline;

                if (self.showingDirections && self.currentPinAnnotationView == view) {

                    [self.mapView addOverlay:polyline];
                    [self.mapView setNeedsDisplay];

                    [self.directionsTableView reloadData];
                }
            }
        }];
    }
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {

    MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];

    MKPolyline *polyline = (MKPolyline *)overlay;

    if ([polyline.title isEqualToString:polylineBetweenStopAndCurrentLocationID]) {
        polylineRenderer.strokeColor = [UIColor purpleColor];
    }
    else {
        polylineRenderer.strokeColor = [UIColor blueColor];
    }
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
            break;
        }
    }
}


#pragma mark - UICollectionView DataSource/Delegate methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    IndexedPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:indexedPhotoCollectionViewCellID forIndexPath:indexPath];

    Photo *photo;

    // if indexpath property is nil, collectionView is in callout accessory
    if (![(IndexedPhotoCollectionView *)collectionView indexPath]) {
        photo = self.photosForSelectedStop[indexPath.row];
    }

    // else, collectionView is in tableViewCell
    else {
        Stop *stop = self.stops[[(IndexedPhotoCollectionView *)collectionView indexPath].row];
        photo = self.stopPhotos[stop.objectId][indexPath.row];
    }

    cell.imageView.image = [UIImage imageNamed:@"blackSquare"];
    cell.imageView.file = photo.image;
    [cell.imageView loadInBackground];

    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    if (![(IndexedPhotoCollectionView *)collectionView indexPath]) {
        return self.photosForSelectedStop.count;
    }
    else {
        Stop *stop = self.stops[[(IndexedPhotoCollectionView *)collectionView indexPath].row];
        return [self.stopPhotos[stop.objectId] count];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    IndexedPhotoCollectionViewCell *cell = (IndexedPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

    Photo *photo;

    // if indexpath property is nil, collectionView is in callout accessory
    if (![(IndexedPhotoCollectionView *)collectionView indexPath]) {
        photo = self.photosForSelectedStop[indexPath.row];
    }

    // else, collectionView is in tableViewCell
    else {
        Stop *stop = self.stops[[(IndexedPhotoCollectionView *)collectionView indexPath].row];
        photo = self.stopPhotos[stop.objectId][indexPath.row];
    }

    [PhotoPopup popupWithImage:cell.imageView.image photo:photo inView:self.view.superview editable:NO delegate:nil];
}

@end




