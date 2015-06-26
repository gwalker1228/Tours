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
#import "IndexedPhotoCollectionView.h"
#import "IndexedPhotoCollectionViewCell.h"
#import "InteractPinAnnotationView.h"
#import <ParseUI/ParseUI.h>

@interface BrowseTourPreviewViewController () <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *photosForSelectedStop;
@property NSMutableArray *stopAnnotations;
@property NSArray *photos;
@property NSArray *stops;
@property NSMutableDictionary *stopPhotos;
@property StopDetailMKPinAnnotationView *currentPinAnnotationView;
@property MKAnnotationView *selectedAnnotationView;

@property BOOL foundPhotosForStop;
@property BOOL removeViewAfterNextSelection;
@property BOOL showingMap;

@end

@implementation BrowseTourPreviewViewController

-(void)viewDidLoad {

    [super viewDidLoad];

    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeHybrid;
    self.stopAnnotations = [NSMutableArray new];
    self.showingMap = YES;


}

-(void)viewWillAppear:(BOOL)animated {

    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    [self loadStops];
    //[self.tableView reloadData];
    self.foundPhotosForStop = NO;
    self.removeViewAfterNextSelection = NO;
}

- (IBAction)onToggleViewPressed:(UIBarButtonItem *)sender {

    if (self.showingMap) {
        [self.view bringSubviewToFront:self.tableView];
        [sender setTitle:@"View Stops in Map"];
    }
    else {
        [self.view bringSubviewToFront:self.mapView];
        [sender setTitle:@"View Stops in List"];
    }

    self.showingMap = !self.showingMap;
}

-(void)loadStops {

    PFQuery *query = [Stop query];
    [query whereKey:@"tour" equalTo:self.tour];
    [query orderByAscending:@"index"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *stops, NSError *error){

        if (!error) {
            self.stops = stops;
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

//-(void)makeDictionaryOfPhotoArrays {
//
//    //self.stopPhotos = [NSMutableDictionary new];
//
//    for (Stop *stop in self.stops) {
//        self.stopPhotos[stop.objectId] = [NSMutableArray new];
//    }
//
//    for (Photo *photo in self.photos) {
//        Stop *photoStop = photo.stop;
//        [self.stopPhotos[photoStop.objectId] addObject:photo];
//    }
//}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    BrowseStopDetailViewController *destinationVC = segue.destinationViewController;

    if ([segue.identifier isEqualToString:@"browseStop"]) {

        destinationVC.stop = self.stops[[self.tableView indexPathForSelectedRow].row];
    }
}


#pragma mark - UITableViewDataSource & Delegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableCellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.stops.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    //    BuildManager *buildManager = [BuildManager sharedBuildManager];
    //    Stop *stop = self.stops[indexPath.row];
    //    buildManager.stop = stop;

    [self performSegueWithIdentifier:@"browseStop" sender:self];
}

#pragma mark - MapView methods

-(void) placeStopAnnotationsOnMap {

    for (Stop *stop in self.stops) {

//        CLLocation *stopLocation = [[CLLocation alloc] initWithLatitude:stop.location.latitude longitude:stop.location.longitude];
        StopPointAnnotation *stopAnnotation = [[StopPointAnnotation alloc] initWithStop:stop];
        //stopAnnotation.title = @" ";
        [self.stopAnnotations addObject:stopAnnotation];
        [self.mapView addAnnotation:stopAnnotation];
    }
    [self.mapView showAnnotations:self.stopAnnotations animated:YES];

    if (self.stops.count > 1) {
        [self generatePolylineForDirectionsFromIndex:0 toIndex:1];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    StopDetailMKPinAnnotationView *annotationView = [[StopDetailMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];

    CGRect stopViewFrame = CGRectMake(0, 0, 200, 150);
    [annotationView.leftCalloutAccessoryView sizeThatFits:stopViewFrame.size];

    annotationView.canShowCallout = YES;
    annotationView.enabled = YES;

    return annotationView;
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {

    if ([(StopDetailMKPinAnnotationView *)view isEqual:self.selectedAnnotationView]) {
        [self.currentPinAnnotationView removeFromSuperview];
        self.selectedAnnotationView = nil;
        [self.mapView deselectAnnotation:view.annotation animated:NO];
    }
    else {
        if (self.currentPinAnnotationView) {
            [self.currentPinAnnotationView removeFromSuperview];
        }
        //    if (self.removeViewAfterNextSelection) {
        //        [self.mapView removeAnnotations:self.stopAnnotations];
        //        [self.mapView addAnnotations:self.stopAnnotations];
        //        self.removeViewAfterNextSelection = NO;
        //        return;
        //    }

        //    CGRect viewAddedToPinFrame = CGRectMake(0, 0, 200, 200);
        //    UIView *viewAddedToPin = [[UIView alloc] initWithFrame:viewAddedToPinFrame];
        //
        //    viewAddedToPin.backgroundColor = [UIColor whiteColor];
        //    [view addSubview:viewAddedToPin];
        //
        StopPointAnnotation *stopPointAnnotation = view.annotation;
        Stop *stop = stopPointAnnotation.stop;
        //
        [self.mapView deselectAnnotation:stopPointAnnotation animated:NO];
        //    self.removeViewAfterNextSelection = YES;
        //
        //
        self.photosForSelectedStop = [self.stopPhotos objectForKey:stop.objectId];
        //
        CGRect stopViewFrame = CGRectMake(0, 0, 200, 150);
        StopDetailMKPinAnnotationView *stopView = [[StopDetailMKPinAnnotationView alloc] initWithFrame:stopViewFrame];
        stopView.backgroundColor = [UIColor whiteColor];
        addSubview:stopView.center = CGPointMake(view.bounds.size.width*0.5f, -stopView.bounds.size.height*0.5f);

        [stopView setCollectionViewDataSourceDelegate:self indexPath:nil];
        stopView.titleLabel.text = stop.title;
        stopView.summaryLabel.text = stop.summary;
        
        self.currentPinAnnotationView = stopView;
        self.selectedAnnotationView = view;
        //[view.leftCalloutAccessoryView sizeThatFits:stopViewFrame.size];

        [view addSubview:stopView];
    }
}

-(void)renderPolylineForRoute:(MKRoute *)route {

    MKPolyline *polyline = [route polyline];
    [self.mapView addOverlay:polyline];
    [self.mapView setNeedsDisplay];
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

        NSArray *routes = response.routes;
        MKRoute *route = routes.firstObject;

        MKPolyline *polyline = [route polyline];
        [self.mapView addOverlay:polyline];
        [self.mapView setNeedsDisplay];

        if (destinationIndex < self.stops.count - 1) {
            [self generatePolylineForDirectionsFromIndex:destinationIndex toIndex:destinationIndex + 1];
        }
    }];
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];

    polylineRenderer.strokeColor = [UIColor blueColor];
    polylineRenderer.lineWidth = 4;

    return polylineRenderer;
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

@end




