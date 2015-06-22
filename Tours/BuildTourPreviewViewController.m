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

@interface BuildTourPreviewViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property NSArray *photos;
@property NSMutableArray *stopAnnotations;
@property NSArray *stops;
@property BOOL foundPhotosForStop;
@property int numberTimesDeselected;

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
        } else {
            // error check
        }
    }];

}

-(void) placeStopAnnotationsOnMap {

    for (Stop *stop in self.stops) {

        CLLocation *stopLocation = [[CLLocation alloc] initWithLatitude:stop.location.latitude longitude:stop.location.longitude];
        StopPointAnnotation *stopAnnotation = [[StopPointAnnotation alloc] initWithLocation:stopLocation forStop:stop];
        stopAnnotation.title = @" ";
        [self.stopAnnotations addObject:stopAnnotation];
        [self.mapView addAnnotation:stopAnnotation];
    }

    [self.mapView showAnnotations:self.stopAnnotations animated:NO];
}

//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
//
//}














@end
