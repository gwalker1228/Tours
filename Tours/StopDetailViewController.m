//
//  StopDetailViewController.m
//  Tours
//
//  Created by Adriana Jimenez Mangas on 6/22/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "StopDetailViewController.h"
#import "StopPhotoCollectionViewCell.h"
#import "BuildTourParentViewController.h"
#import "Photo.h"
#import "Stop.h"
#import "StopPointAnnotation.h"

static NSString *reuseIdentifier = @"PhotoCell";

@interface StopDetailViewController () <MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, getter=isEditing) BOOL editing;

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *summaryTextView;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property UIImageView *imageView;
@property UIView *blackView;

@property NSArray *photos;

@end

@implementation StopDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", NSStringFromClass([self class]));

    [self setInitialCollectionViewLayout];

    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeHybrid;

    BuildManager *buildManager = [BuildManager sharedBuildManager];
    Tour *tour = buildManager.tour;

    PFQuery *stopsQuery = [Stop query];
    [stopsQuery whereKey:@"tour" equalTo:tour];

    [stopsQuery findObjectsInBackgroundWithBlock:^(NSArray *stops, NSError *error) {

        self.stop = stops.firstObject;
        [self setup];
        [self placeAnnotationViewOnMapForStopLocation];
        NSLog(@"%@", self.stop.title);

    }];


//    self.titleTextField.text = self.stop.title;
//    self.summaryTextView.text = self.stop.summary;
//    self.titleTextField.delegate = self;
//    self.summaryTextView.delegate = self;
}


- (void)setup {

    self.titleTextField.text = self.stop.title;
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

    CLLocation *stopLocation = [[CLLocation alloc] initWithLatitude:self.stop.location.latitude longitude:self.stop.location.longitude];
    StopPointAnnotation *stopAnnotation = [[StopPointAnnotation alloc] initWithLocation:stopLocation forStop:self.stop];

    stopAnnotation.title = @" ";

    [self.mapView addAnnotation:stopAnnotation];
    [self zoomToRegionAroundAnnotation];
}


- (void) zoomToRegionAroundAnnotation {

    CLLocationCoordinate2D stopCLLocationCoordinate2D = CLLocationCoordinate2DMake(self.stop.location.latitude + 0.002, self.stop.location.longitude);
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(stopCLLocationCoordinate2D, 100000, 100000);
    [self.mapView setRegion:coordinateRegion animated:NO];
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
}

//- (void)viewWillDisappear:(BOOL)animated {
//    self.stop.title = self.titleTextField.text;
//    self.stop.summary = self.summaryTextView.text;
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [[self view] endEditing:YES];
    return true;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{

    if ([text isEqualToString:@"\n"]) {

        [textView resignFirstResponder];
        return NO;
    }

    return YES;
}


- (void)setInitialCollectionViewLayout {

    [self.collectionView registerClass:[StopPhotoCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];

    self.collectionView.backgroundColor = [UIColor darkGrayColor];
    self.collectionView.layer.borderColor = [UIColor blackColor].CGColor;
    self.collectionView.layer.borderWidth = 1.0;
    CGFloat collectionWidth = (self.view.bounds.size.width / 3) - 1;

    /**** new size ****/
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
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

    StopPhotoCollectionViewCell *cell = [[StopPhotoCollectionViewCell alloc] init];
    cell = (StopPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];

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



