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

@interface BuildStopLocationViewController () <MKMapViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;



@property CLLocation *locationUser;
@property CLLocationManager *locationManager;
@property CLGeocoder *geocoder;

@property StopPointAnnotation *stopPointAnnotation;
@property BOOL pinDropped;

@end

@implementation BuildStopLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.geocoder = [CLGeocoder new];


    self.mapView.mapType = MKMapTypeHybrid;
    self.mapView.pitchEnabled = YES; // doesn't seem to do much. The reference makes it sound like this is auto set based on the camera
    self.mapView.showsBuildings = YES;

//    MKMapCamera *camera = [MKMapCamera new];
//    camera.centerCoordinate = self.mapView.centerCoordinate;
//    [self.mapView setCamera:camera];
}

-(void)dropPin {

    UIImage *pinImage = [UIImage imageNamed:@"redPin"];
    CGFloat pinWidth = 40;
    CGFloat pinHeight = 60;

    // create the imageView that defines centers the pin in the 
    UIImageView *pin = [[UIImageView alloc] initWithFrame:CGRectMake(self.mapView.center.x - pinWidth/2, self.mapView.center.y-pinHeight/2, pinWidth, pinHeight)];
    pin.image = pinImage;

    pin.userInteractionEnabled = NO;

    [self.view addSubview:pin];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    [self.geocoder geocodeAddressString:searchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {

        [self.mapView removeAnnotations:self.mapView.annotations];
        MKPlacemark *placemark = placemarks.firstObject;

        self.stopPointAnnotation = [[StopPointAnnotation alloc] initWithLocation:placemark.location forStop:nil];
        [self.mapView addAnnotation:self.stopPointAnnotation];

        [self.mapView showAnnotations:self.mapView.annotations animated:YES];

        [self.searchBar resignFirstResponder];

        if (!self.pinDropped) {
            [self dropPin];
        }
    }];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    MKAnnotationView *pin = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];

//   pin.draggable = YES;
//   StopPointAnnotation *stop = annotation;

    return pin;
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
//    NSLog(@"%f, %f", mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude);
    CLLocationCoordinate2D mapCenter = mapView.centerCoordinate;
    self.stop.location = [PFGeoPoint geoPointWithLatitude:mapCenter.latitude longitude:mapCenter.longitude];
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
//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
//    CLLocation *location = locations.firstObject;
//    if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {
//        self.locationUser = location;
//        [self.clLocationManager stopUpdatingLocation];
//    }
//}




@end
