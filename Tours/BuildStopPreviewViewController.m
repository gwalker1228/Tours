//
//  BuildStopPreviewViewController.m
//  Tours
//
//  Created by Mark Porcella on 6/14/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BuildStopPreviewViewController.h"
#import <MapKit/MapKit.h>
#import "StopPointAnnotation.h"
#import "MapPreviewView.h"
#import "Photo.h"
#import "IndexedPhotoCollectionView.h"
#import "IndexedPhotoCollectionViewCell.h"
#import "InteractPinAnnotationView.h" // subclassed AnnotationView to allow touch events inside mapView
#import <ParseUI/ParseUI.h>

@interface BuildStopPreviewViewController () <MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property NSArray *photos;
@property NSArray *stopAnnotations;
@property BOOL foundPhotosForStop;
@property int numberTimesDeselected;

@end

@implementation BuildStopPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeHybrid;

}

- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:NO];
    self.foundPhotosForStop = NO;
    if (self.stop.location != nil) {
        [self placeAnnotationViewOnMapForStopLocation];
    }
}

- (void) findPhotosForSelectedStop:(Stop *)stop {

    self.foundPhotosForStop = YES;
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"stop" equalTo:stop];
    [query orderByAscending:@"order"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *photos, NSError *error){
        self.photos = photos;
        [self.mapView removeAnnotations:self.stopAnnotations];
        [self.mapView addAnnotations:self.stopAnnotations];
            // selects the annotation after the photos are added
        [self.mapView selectAnnotation:self.stopAnnotations.firstObject animated:YES];
    }];
}


// Auto selects the first annotation View when the view first loads, after the photos are loaded it doesn't autoselect
-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {

    if (self.foundPhotosForStop == NO) {
        InteractPinAnnotationView *view = [views firstObject];
        [self.mapView selectAnnotation:view.annotation animated:YES];
    }
}

- (void) placeAnnotationViewOnMapForStopLocation {

    CLLocation *stopLocation = [[CLLocation alloc] initWithLatitude:self.stop.location.latitude longitude:self.stop.location.longitude];
    StopPointAnnotation *stopAnnotation = [[StopPointAnnotation alloc] initWithLocation:stopLocation forStop:self.stop];

    stopAnnotation.title = @" ";

    self.stopAnnotations = [NSArray arrayWithObject:stopAnnotation]; // set this in an array so I can remove and add it again when the photos have been retrieved *the remove annotation requires an array

    [self.mapView addAnnotation:stopAnnotation];
    [self zoomToRegionAroundAnnotation];
}

- (void) zoomToRegionAroundAnnotation {
    // zoom to slightly above the point to give room for the annotation view
    CLLocationCoordinate2D stopCLLocationCoordinate2D = CLLocationCoordinate2DMake(self.stop.location.latitude + 0.002, self.stop.location.longitude);
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(stopCLLocationCoordinate2D, 1000, 1000);
    [self.mapView setRegion:coordinateRegion animated:NO];

}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    InteractPinAnnotationView *annotationView = [[InteractPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];

    annotationView.canShowCallout = YES;
    annotationView.enabled = YES;
    return annotationView;

    //    annotationView.image = [UIImage imageNamed:@"redPin"];


//    UIView *vw = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
//    vw.backgroundColor = [UIColor redColor];
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 250, 250)];
//    label.numberOfLines = 4;
//    label.text = @"hello\nhow are you\nfine";
//    [vw addSubview:label];
//    annotationView.leftCalloutAccessoryView = vw;


//    CGRect calloutViewFrame = CGRectMake(0, 0, 250, 250);
//    UIView *callOutView = [[UIView alloc] initWithFrame:calloutViewFrame];
    //addSubview:callOutView.center = CGPointMake(view.bounds.size.width*0.5f, -callOutView.bounds.size.height*0.5f);
//    callOutView.backgroundColor = [UIColor whiteColor];
   // [view addSubview:callOutView];

    // find the stop associated with the annotationView.annotation
    //StopPointAnnotation *stopPointAnnotation = view.annotation;



    // add view that contains the collection view

//    pin.leftCalloutAccessoryView = [[UIView alloc] initWithFrame:calloutViewFrame];
//    pin.leftCalloutAccessoryView.backgroundColor = [UIColor whiteColor];
//    [pin.leftCalloutAccessoryView sizeToFit];
//    pin.leftCalloutAccessoryView = callOutView;

//    pin.leftCalloutAccessoryView = [[UIView alloc] initWithFrame:calloutViewFrame];
//    pin.leftCalloutAccessoryView.backgroundColor = [UIColor whiteColor];
//    [pin.leftCalloutAccessoryView sizeToFit];
    //    pin.leftCalloutAccessoryView = callOutView;

//    MapPreviewView *stopView = [[MapPreviewView alloc] initWithFrame:calloutViewFrame];
//    [stopView setCollectionViewDataSourceDelegate:self]; // the stopView contains the collection view, give this VC the delegate
//    stopView.titleLabel.text = stop.title;
//    stopView.summaryLabel.text = stop.summary;
//    [pin.leftCalloutAccessoryView addSubview:stopView];



}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {


    if (self.numberTimesDeselected > 1) {
//        [self.mapView removeAnnotation:view.annotation];
//        [self.mapView addAnnotation:view.annotation];

        // resets the annotation views. I autodeselect the annotiation pin because the calloutView gets in the way of the collection view
        // If the user taps it again, I remove the annootaions and re-add them because thats the only way to get rid of the collective view
        [self.mapView removeAnnotations:self.stopAnnotations];
        [self.mapView addAnnotations:self.stopAnnotations];
        self.numberTimesDeselected = 0;
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
//

    // the calloutview gets in the way of collection view we add, so we want to deselect it right away
    [mapView deselectAnnotation:view.annotation animated:NO];
    // also want to allow user to deselect the view, so if it's deselected twice we reomove the annotiation, the add it again which removes the collection view
    self.numberTimesDeselected++;

    // adding the view that will contain the MapPreviewView
    CGRect viewAddedToPinFrame = CGRectMake(0, 0, 250, 250);
    UIView *viewAddedToPin = [[UIView alloc] initWithFrame:viewAddedToPinFrame];

    addSubview:viewAddedToPin.center = CGPointMake(view.bounds.size.width*0.5f, -viewAddedToPin.bounds.size.height*0.5f);
    viewAddedToPin.backgroundColor = [UIColor whiteColor];
    [view addSubview:viewAddedToPin];

    // find the stop associated with the annotationView.annotation
    StopPointAnnotation *stopPointAnnotation = view.annotation;
    Stop *stop = stopPointAnnotation.stop;

    // add view that contains the collection view
    MapPreviewView *stopView = [[MapPreviewView alloc] initWithFrame:viewAddedToPinFrame];
    [stopView setCollectionViewDataSourceDelegate:self]; // the stopView contains the collection view, give this VC the delegate
    stopView.titleLabel.text = stop.title;
    stopView.summaryLabel.text = stop.summary;
    [viewAddedToPin addSubview:stopView];

    // load all the photos for this stop - this method also removes are readloads the annotations when the photos are selected
    if (self.foundPhotosForStop == NO) {
        [self findPhotosForSelectedStop:stop];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    IndexedPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:indexedPhotoCollectionViewCellID forIndexPath:indexPath];

    Photo *photo = [self.photos objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"redPin"]; // placeholder image
    cell.imageView.file = photo.image;
    [cell.imageView.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {

        cell.imageView.image = [UIImage imageWithData:data];
    }];

    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.photos count];
}












@end
