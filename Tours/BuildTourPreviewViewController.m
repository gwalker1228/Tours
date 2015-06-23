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
@property NSMutableDictionary *stopPhotos;
@property BOOL foundPhotosForStop;
//@property int numberTimesDeselected;
@property BOOL removeViewAfterNextSelection;

@end

@implementation BuildTourPreviewViewController

-(void) viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeHybrid;
    self.stopAnnotations = [NSMutableArray new];

}

-(void) viewWillAppear:(BOOL)animated {
    self.foundPhotosForStop = NO;
    self.removeViewAfterNextSelection = NO;
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
            [self findPhotosForTour];
        } else {
            // error check
        }
    }];

}

-(void) findPhotosForTour {

    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"tour" equalTo:self.tour];
    [query findObjectsInBackgroundWithBlock:^(NSArray *photos, NSError *error) {

        self.photos = photos;
        [self makeDictionaryOfPhotoArrays];
    }];

}

-(void) makeDictionaryOfPhotoArrays {

    self.stopPhotos = [NSMutableDictionary new];

    for (Stop *stop in self.stops) {
        self.stopPhotos[stop.objectId] = [NSMutableArray new];
    }

    for (Photo *photo in self.photos) {

        Stop *photoStop = photo.stop;
        [self.stopPhotos[photoStop.objectId] addObject:photo];

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
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    InteractPinAnnotationView *annotationView = [[InteractPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];

    annotationView.canShowCallout = YES;
    annotationView.enabled = YES;
    return annotationView;
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {


    if (self.removeViewAfterNextSelection) {
        [self.mapView removeAnnotations:self.stopAnnotations];
        [self.mapView addAnnotations:self.stopAnnotations];
        self.removeViewAfterNextSelection = NO;
        return;
    }

    CGRect viewAddedToPinFrame = CGRectMake(0, 0, 250, 250);
    UIView *viewAddedToPin = [[UIView alloc] initWithFrame:viewAddedToPinFrame];

    addSubview:viewAddedToPin.center = CGPointMake(view.bounds.size.width*0.5f, -viewAddedToPin.bounds.size.height*0.5f);
    viewAddedToPin.backgroundColor = [UIColor whiteColor];
    [view addSubview:viewAddedToPin];

    StopPointAnnotation *stopPointAnnotation = view.annotation;
    Stop *stop = stopPointAnnotation.stop;

    [self.mapView deselectAnnotation:stopPointAnnotation animated:NO];
    self.removeViewAfterNextSelection = YES;


    self.photosForSelectedStop = [self.stopPhotos objectForKey:stop.objectId];

    MapPreviewView *stopView = [[MapPreviewView alloc] initWithFrame:viewAddedToPinFrame];

    [stopView setCollectionViewDataSourceDelegate:self];
    stopView.titleLabel.text = stop.title;
    stopView.summaryLabel.text = stop.summary;
    [viewAddedToPin addSubview:stopView];

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
