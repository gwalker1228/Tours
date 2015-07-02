//
//  BrowseStopDetailViewController.m
//  Tours
//
//  Created by Gretchen Walker on 6/25/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BrowseStopDetailViewController.h"
#import <MapKit/MapKit.h>
#import "StopPhotoCollectionViewCell.h"
#import "BuildStopLocationViewController.h"
#import "BuildStopPhotosViewController.h"
#import "Photo.h"
#import "Stop.h"
#import "PhotoPopup.h"
#import "StopPointAnnotation.h"

static NSString *reuseIdentifier = @"PhotoCell";

@interface BrowseStopDetailViewController () <MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *summaryTextView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property UIButton *setLocationButton;
@property UIButton *addLocationButton;
@property NSArray *photos;

@property BOOL didSetupSetLocationButton;

@end

@implementation BrowseStopDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setInitialCollectionViewLayout];

    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeHybrid;

    self.summaryTextView.editable = NO;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Open in Maps" style:UIBarButtonItemStylePlain target:self action:@selector(openStopInMaps)];
    // change to designables:
//    self.summaryTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    self.summaryTextView.layer.borderWidth = 0.5;
//    self.summaryTextView.layer.cornerRadius = 7;
}

- (void)viewWillAppear:(BOOL)animated {

    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];

    [self updateViews];

    [self placeAnnotationViewOnMapForStopLocation];
}

- (void)updateViews {

    self.titleLabel.text = self.stop.title;
    self.summaryTextView.text = self.stop.summary;

    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.layer.borderColor = [UIColor clearColor].CGColor;
    self.titleLabel.font = [UIFont fontWithName:self.titleLabel.font.fontName size:20];

    self.summaryTextView.backgroundColor = [UIColor clearColor];
    self.summaryTextView.layer.borderColor = [UIColor clearColor].CGColor;
    [self.summaryTextView setContentOffset:CGPointMake(0, 0)];

    PFQuery *query = [Photo query];
    [query whereKey:@"stop" equalTo:self.stop];
    [query orderByAscending:@"order"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *photos, NSError *error) {

        self.photos = photos;
        [self.collectionView reloadData];
    }];
}

- (void)placeAnnotationViewOnMapForStopLocation {

    [self.mapView removeAnnotations:self.mapView.annotations];

//    CLLocation *stopLocation = [[CLLocation alloc] initWithLatitude:self.stop.location.latitude longitude:self.stop.location.longitude];
    StopPointAnnotation *stopAnnotation = [[StopPointAnnotation alloc] initWithStop:self.stop];

    //stopAnnotation.title = @" ";

    [self.mapView addAnnotation:stopAnnotation];
    [self zoomToRegionAroundAnnotation];
}

- (void)openStopInMaps {

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Open Maps Application?" message:@"Viewing stop in Maps application will close Tourpedia app" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Proceed", nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 1) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.stop.location.latitude, self.stop.location.longitude);
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];

        CLGeocoder *geocoder = [CLGeocoder new];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];

        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            MKPlacemark *placemark = placemarks[0];
            mapItem.name = [NSString stringWithFormat:@"%@%@", placemark.subThoroughfare ? [NSString stringWithFormat:@"%@, ", placemark.subThoroughfare] : @"", placemark.thoroughfare ? : @""];
            [mapItem openInMapsWithLaunchOptions:nil];
        }];
    }
}


- (void)zoomToRegionAroundAnnotation {

    CLLocationCoordinate2D stopCLLocationCoordinate2D = CLLocationCoordinate2DMake(self.stop.location.latitude + 0.002, self.stop.location.longitude);
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(stopCLLocationCoordinate2D, 10000, 10000);
    [self.mapView setRegion:coordinateRegion animated:NO];
}


- (void)setInitialCollectionViewLayout {

    [self.collectionView registerClass:[StopPhotoCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];

    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.layer.borderColor = [UIColor blackColor].CGColor;
    self.collectionView.layer.borderWidth = 1.0;
    CGFloat collectionWidth = self.collectionView.layer.bounds.size.height; //(self.view.bounds.size.width / 3) - 1;

    /**** new size ****/
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = CGSizeMake(collectionWidth, collectionWidth);
    [flowLayout setMinimumInteritemSpacing:1.0f];
    [flowLayout setMinimumLineSpacing:1.0f];
    [self.collectionView setCollectionViewLayout:flowLayout];

}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    StopPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];

    Photo *photo = self.photos[indexPath.row];
    cell.imageView.file = photo.image;

    [cell.imageView loadInBackground];

    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    StopPhotoCollectionViewCell *cell = (StopPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];

    Photo *photo = self.photos[indexPath.row];

    [PhotoPopup popupWithImage:cell.imageView.image photo:photo inView:self.view editable:NO delegate:nil];
}


@end




