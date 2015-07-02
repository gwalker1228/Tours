//
//  BuildStopLocationViewController.m
//  Tours
//
//  Created by Mark Porcella on 6/14/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

/*
 TODO: May want to improve animation when searching after the first time (eg zoom out/zoom in)

 
*/

#import "BuildStopLocationViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "StopPointAnnotation.h"

@interface BuildStopLocationViewController () <MKMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;



@property CLLocation *locationUser;
@property CLLocationManager *clLocationManager;
@property CLGeocoder *geocoder;

@property StopPointAnnotation *stopPointAnnotation;
@property BOOL pinDropped;
@property BOOL pinViewDropped;

@end

@implementation BuildStopLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.geocoder = [CLGeocoder new];

    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeHybrid;

    self.mapView.pitchEnabled = YES; // doesn't seem to do much. The reference makes it sound like this is auto set based on the camera
    self.mapView.showsBuildings = YES;

//    CLLocation *stopLocation = [[CLLocation alloc] initWithLatitude:self.stop.location.latitude longitude:self.stop.location.longitude];
//    StopPointAnnotation *stopAnnotation = [[StopPointAnnotation alloc] initWithLocation:stopLocation forStop:self.stop];
//    stopAnnotation.title = @" ";
//    [self.mapView addAnnotation:stopAnnotation];


//    [self dropPin];




//    MKMapCamera *camera = [MKMapCamera new];
//    camera.centerCoordinate = self.mapView.centerCoordinate;
//    [self.mapView setCamera:camera];
}


-(void)viewDidLayoutSubviews {
//    [self dropPin];

    if (!self.pinViewDropped) {
        if (self.stop.location == nil) {
            [self findUserLocation];
        }
        else {
            [self zoomMapToSavedStopLocation];
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.coordinate = CLLocationCoordinate2DMake(self.stop.location.latitude, self.stop.location.longitude);
            [self.mapView addAnnotation:annotation];
            self.pinViewDropped = YES;
            CGPoint p = [self.mapView convertCoordinate:annotation.coordinate toPointToView:self.mapView]; // TO DELETE!
            NSLog(@"use this %@", NSStringFromCGPoint(p));
            [self dropPin];
        }
    }

}


- (void) findUserLocation {
    if (nil == self.clLocationManager) {
        self.clLocationManager = [[CLLocationManager alloc] init];
    }
    self.clLocationManager.delegate = self;
    [self.clLocationManager requestWhenInUseAuthorization];
    [self.clLocationManager startUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = locations.firstObject;
    if (location.verticalAccuracy < 10000 && location.horizontalAccuracy < 10000) {
        self.locationUser = location;
        MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 100000, 10000);
        [self.mapView setRegion:coordinateRegion animated:NO];
        [self.clLocationManager stopUpdatingLocation];

        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake(self.mapView.centerCoordinate.latitude, self.mapView.centerCoordinate.longitude);
        [self.mapView addAnnotation:annotation];
        self.pinViewDropped = YES;
        CGPoint p = [self.mapView convertCoordinate:annotation.coordinate toPointToView:self.mapView];  // TO DELETE!!
        NSLog(@"use this %@", NSStringFromCGPoint(p));
        CLLocationCoordinate2D mapCenter = self.mapView.centerCoordinate;
        self.stop.location = [PFGeoPoint geoPointWithLatitude:mapCenter.latitude longitude:mapCenter.longitude];
        [self dropPin];

    }
}


-(void)dropPin {

    if (!self.pinDropped) {
        UIImage *pinImage = [UIImage imageNamed:@"redPin"];

        CGFloat pinWidth = 40;
        CGFloat pinHeight = 60;

        // create the imageView that defines centers the pin in the
        //UIImageView *pin = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x - pinWidth/2, self.view.center.y - pinHeight, pinWidth, pinHeight)];

        CGPoint p = [self.mapView convertCoordinate:[[self.mapView.annotations firstObject] coordinate] toPointToView:self.mapView];

//        UIImageView *pin = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x - pinWidth/2, self.view.center.y - pinHeight, pinWidth, pinHeight)];
        UIImageView *pin = [[UIImageView alloc] initWithFrame:CGRectMake(p.x - pinWidth/2, p.y - pinHeight, pinWidth, pinHeight)];

//        pin.hidden = YES;

//        UIImageView *pin = [[UIImageView alloc] initWithFrame:CGRectMake(self.mapView.center.x, self.mapView.center.y, pinWidth, pinHeight)];
        pin.image = pinImage;

        pin.userInteractionEnabled = NO;

//        [self.view addSubview:pin];
        [self.mapView addSubview:pin];
//        [self.view addSubview:pin];
        self.pinDropped = YES;
    }
}


- (void) zoomMapToSavedStopLocation {
    if (self.stop.location) {
//        [self dropPin];
        CLLocationCoordinate2D stopCLLocationCoordinate2D = CLLocationCoordinate2DMake(self.stop.location.latitude, self.stop.location.longitude);
        MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(stopCLLocationCoordinate2D, 1000, 1000);
        [self.mapView setRegion:coordinateRegion animated:NO];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    [self.geocoder geocodeAddressString:searchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
//
//        [self.mapView removeAnnotations:self.mapView.annotations];
        MKPlacemark *placemark = placemarks.firstObject;
        CLLocationCoordinate2D stopCLLocationCoordinate2D = placemark.location.coordinate;
//
//        self.stopPointAnnotation = [[StopPointAnnotation alloc] initWithLocation:placemark.location forStop:nil];
//        [self.mapView addAnnotation:self.stopPointAnnotation];
//
//        [self.mapView showAnnotations:self.mapView.annotations animated:YES];

//        CLLocationCoordinate2D stopCLLocationCoordinate2D = CLLocationCoordinate2DMake(self.stop.location.latitude, self.stop.location.longitude);
        MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(stopCLLocationCoordinate2D, 1000, 1000);
        [self.mapView setRegion:coordinateRegion animated:NO];


        [self.searchBar resignFirstResponder];

//        [self dropPin];
    }];
}


-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    MKAnnotationView *pin = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];

//   pin.draggable = YES;
//   StopPointAnnotation *stop = annotation;

    return pin;
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (self.pinViewDropped) {
//        [self dropPin];
        CLLocationCoordinate2D mapCenter = mapView.centerCoordinate;
        self.stop.location = [PFGeoPoint geoPointWithLatitude:mapCenter.latitude longitude:mapCenter.longitude];
    }
   // [self dropPin];

}

- (IBAction)onSaveButtonPressed:(UIBarButtonItem *)sender {

    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    [self.stop saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    self.clLocationManager = [CLLocationManager new];
//    [self.clLocationManager requestWhenInUseAuthorization];
//    [self.clLocationManager startUpdatingLocation];
//
//    
//}
//





@end
