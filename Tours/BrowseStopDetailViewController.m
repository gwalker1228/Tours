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
#import "StopPointAnnotation.h"

static NSString *reuseIdentifier = @"PhotoCell";

@interface BrowseStopDetailViewController () <MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *summaryTextView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property UIImageView *imageView;
@property UIView *blackView;
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
    // change to designables:
//    self.summaryTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    self.summaryTextView.layer.borderWidth = 0.5;
//    self.summaryTextView.layer.cornerRadius = 7;
}

- (void)viewWillAppear:(BOOL)animated {

    [self updateViews];

    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];

    [self placeAnnotationViewOnMapForStopLocation];

}

- (void)updateViews {

    self.titleLabel.text = self.stop.title;
    self.summaryTextView.text = self.stop.summary;

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

    self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.imageView.image = cell.imageView.image;
    self.imageView.frame = CGRectMake(self.view.center.x, self.view.center.y, 0, 0);

    CGFloat imageSize = self.view.bounds.size.width;
    CGFloat originx = self.view.center.x - (imageSize / 2);
    CGFloat originy = self.view.center.y - (imageSize / 2);

    self.blackView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.blackView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    [self.view addSubview:self.blackView];

    [UIView animateWithDuration:.5 animations:^{

        [self.view addSubview:self.imageView];
        self.imageView.frame = CGRectMake(originx, originy, imageSize, imageSize);
        [self.view bringSubviewToFront:self.imageView];

    } completion:^(BOOL finished) {

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:self action:@selector(onViewTapped)];

        [self.imageView addGestureRecognizer:tap];
        [self.blackView addGestureRecognizer:tap];
    }];
}


- (void)onViewTapped {

    [UIView animateWithDuration:0.1 animations:^{

        self.imageView.frame = CGRectMake(self.view.center.x, self.view.center.y, 1, 1);
        self.blackView.frame = CGRectMake(self.view.center.x, self.view.center.y, 1, 1);

    } completion:^(BOOL finished) {
        
        [self.imageView removeFromSuperview];
        [self.blackView removeFromSuperview];
    }];
}


@end



