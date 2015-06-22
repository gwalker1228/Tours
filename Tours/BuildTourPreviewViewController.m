//
//  BuildTourPreviewViewController.m
//  Tours
//
//  Created by Mark Porcella on 6/22/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BuildTourPreviewViewController.h"
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "StopPointAnnotation.h"
#import "MapPreviewView.h"
#import "Photo.h"
#import "Stop.h"
#import "IndexedPhotoCollectionView.h"
#import "IndexedPhotoCollectionViewCell.h"
#import "InteractPinAnnotationView.h"
#import <ParseUI/ParseUI.h>

@interface BuildTourPreviewViewController () <MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property NSArray *photosForSelectedStop;
@property NSMutableArray *stopAnnotations;
@property NSArray *photos;
@property NSArray *stops;
@property BOOL foundPhotosForStop;
@property int numberTimesDeselected;
@property BOOL removeViewAfterSelection;

@end

@implementation BuildTourPreviewViewController

-(void) viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeHybrid;
    self.stopAnnotations = [NSMutableArray new];
    // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated {
    self.foundPhotosForStop = NO;
    self.removeViewAfterSelection = NO;
    [self findStopsForTour];

}

-(void) findStopsForTour {

    PFQuery *query = [PFQuery queryWithClassName:@"Stop"];
    [query whereKey:@"tour" equalTo:self.tour];
//    [query orderByAscending:@"order"]; Need to add the order number in the stops
    [query findObjectsInBackgroundWithBlock:^(NSArray *stops, NSError *error){

        if (error == nil) {
            self.stops = stops;
            [self placeStopAnnotationsOnMap];
            [self findStopsForTour];
        } else {
            // error check
        }
    }];

}

-(void) findPhotosForTour {

    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"stop" equalTo:self.tour];
    [query findObjectsInBackgroundWithBlock:^(NSArray *photos, NSError *error) {

        self.photos = photos;

    }];

}

-(void) makeDictionaryOfPhotoArrays {

    for (Stop *stop in self.stops) {

        

    }


}


-(void) placeStopAnnotationsOnMap {

    for (Stop *stop in self.stops) {

        CLLocation *stopLocation = [[CLLocation alloc] initWithLatitude:stop.location.latitude longitude:stop.location.longitude];
        StopPointAnnotation *stopAnnotation = [[StopPointAnnotation alloc] initWithLocation:stopLocation forStop:stop];
        stopAnnotation.title = @" ";
        [self.stopAnnotations addObject:stopAnnotation];
        [self.mapView addAnnotation:stopAnnotation];
    }

//    [self.mapView showAnnotations:self.stopAnnotations animated:NO];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    InteractPinAnnotationView *annotationView = [[InteractPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];

    annotationView.canShowCallout = YES;
    annotationView.enabled = YES;
    return annotationView;
}

-(void) findPhotosForSelectedStop:(Stop *)stop annotation:(StopPointAnnotation *)annotation view:(MKAnnotationView *)view {

    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"stop" equalTo:stop];
    [query orderByAscending:@"order"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *photos, NSError *error) {
        self.photosForSelectedStop = photos;
        [self.mapView removeAnnotations:self.stopAnnotations];
        [self.mapView addAnnotations:self.stopAnnotations];


        [self.mapView selectAnnotation:annotation animated:NO];
//        [self.mapView deselectAnnotation:annotation animated:NO];
//        [self.mapView deselectAnnotation:annotation animated:NO];
        self.foundPhotosForStop = YES;
        NSLog(@"annotation description: %@", annotation.description);

        //        self.removeViewAfterSelection = YES;
    }];
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {

//
//    if (self.removeViewAfterSelection) {
//        [self.mapView removeAnnotations:self.stopAnnotations];
//        [self.mapView addAnnotations:self.stopAnnotations];
//        self.removeViewAfterSelection = NO;
//        return;
//    }

    CGRect viewAddedToPinFrame = CGRectMake(0, 0, 250, 250);
    UIView *viewAddedToPin = [[UIView alloc] initWithFrame:viewAddedToPinFrame];

    addSubview:viewAddedToPin.center = CGPointMake(view.bounds.size.width*0.5f, -viewAddedToPin.bounds.size.height*0.5f);
    viewAddedToPin.backgroundColor = [UIColor whiteColor];
    [view addSubview:viewAddedToPin];

    StopPointAnnotation *stopPointAnnotation = view.annotation;
    Stop *stop = stopPointAnnotation.stop;

    [self.mapView deselectAnnotation:stopPointAnnotation animated:NO];

    MapPreviewView *stopView = [[MapPreviewView alloc] initWithFrame:viewAddedToPinFrame];
    [stopView setCollectionViewDataSourceDelegate:self];
    stopView.titleLabel.text = stop.title;
    stopView.summaryLabel.text = stop.summary;
    [viewAddedToPin addSubview:stopView];

//    [self addCollectionViewToAnnotationView:view forAnnotaion:view.annotation];



//    self.foundPhotosForStop = NO;


    if (self.foundPhotosForStop == NO) {
        [self findPhotosForSelectedStop:stop annotation:view.annotation view:view];
    }

}

//- (void) addCollectionViewToAnnotationView:(MKAnnotationView *)view forAnnotaion:(StopPointAnnotation *)annotation {
//
//    CGRect viewAddedToPinFrame = CGRectMake(0, 0, 250, 250);
//    UIView *viewAddedToPin = [[UIView alloc] initWithFrame:viewAddedToPinFrame];
//
//addSubview:viewAddedToPin.center = CGPointMake(view.bounds.size.width*0.5f, -viewAddedToPin.bounds.size.height*0.5f);
//    viewAddedToPin.backgroundColor = [UIColor whiteColor];
//    [view addSubview:viewAddedToPin];
//
//    StopPointAnnotation *stopPointAnnotation = view.annotation;
//    Stop *stop = stopPointAnnotation.stop;
//
//
//    MapPreviewView *stopView = [[MapPreviewView alloc] initWithFrame:viewAddedToPinFrame];
//    [stopView setCollectionViewDataSourceDelegate:self];
//    stopView.titleLabel.text = stop.title;
//    stopView.summaryLabel.text = stop.summary;
//    [viewAddedToPin addSubview:stopView];
//
//
//}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {

    self.numberTimesDeselected++;
    if (self.numberTimesDeselected > 1) {
        [self.mapView removeAnnotations:self.stopAnnotations];
        [self.mapView addAnnotations:self.stopAnnotations];
        self.numberTimesDeselected = 0;
        self.foundPhotosForStop = NO;
    }

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    IndexedPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:indexedPhotoCollectionViewCellID forIndexPath:indexPath];

    Photo *photo = [self.photosForSelectedStop objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"redPin"];
    cell.imageView.file = photo.image;
    [cell.imageView.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {

        cell.imageView.image = [UIImage imageWithData:data];
    }];
    return cell;

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return [self.photosForSelectedStop count];
}










@end
