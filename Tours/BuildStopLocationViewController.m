//
//  BuildStopLocationViewController.m
//  Tours
//
//  Created by Mark Porcella on 6/14/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BuildStopLocationViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface BuildStopLocationViewController ()

@property CLLocation *locationUser;
@property CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation BuildStopLocationViewController

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    self.clLocationManager = [CLLocationManager new];
//    [self.clLocationManager requestWhenInUseAuthorization];
//    [self.clLocationManager startUpdatingLocation];
//
//    
//}
//
//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
//    CLLocation *location = locations.firstObject;
//    if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {
//        self.locationUser = location;
//        [self.clLocationManager stopUpdatingLocation];
//    }
//}




@end
