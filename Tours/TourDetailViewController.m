//
//  TourDetailViewController.m
//  Tours
//
//  Created by Gretchen Walker on 6/22/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "TourDetailViewController.h"
#import "TourPhotoCollectionViewCell.h"
#import "StopPointAnnotation.h"
#import "SummaryTextView.h"
#import "Stop.h"
#import "Photo.h"
#import <MapKit/MapKit.h>
#import <ParseUI/ParseUI.h>




@interface TourDetailViewController () <MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, SummaryTextViewDelegate>

@property (weak, nonatomic) IBOutlet PFImageView *coverPhotoImageView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
//@property (weak, nonatomic) IBOutlet UILabel *stopTitle;
@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;
@property (weak, nonatomic) IBOutlet UIView *tourDetailView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tourDetailViewHeightConstraint;

@property UILabel *estimatedDistanceLabel;
@property UILabel *estimatedTimeLabel;
@property UILabel *distanceFromCurrentLocationLabel;
@property UILabel *ratingsLabel;
@property SummaryTextView *summaryTextView;
@property UIButton *moreButton;
@property UIButton *addStopButton;

@property NSArray *stops;
@property NSMutableDictionary *photos;

@end

@implementation TourDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {

    self.titleTextField.text = self.tour.title ? : @"New Tour";
    self.tour.title = self.titleTextField.text;

    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    [self setupViews];
    [self loadStops];
}

- (void)loadStops {

    PFQuery *query = [Stop query];
    [query whereKey:@"tour" equalTo:self.tour];
    [query orderByAscending:@"orderIndex"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *stops, NSError *error) {
        self.stops = stops;
        [self loadStopsOnMap];
        [self loadPhotos];
    }];
}

- (void)loadPhotos {

    self.photos = [NSMutableDictionary new];

    for (Stop *stop in self.stops) {

        self.photos[stop.objectId] = [NSMutableArray new];
    }

    PFQuery *query = [Photo query];
    [query whereKey:@"tour" equalTo:self.tour];
    [query orderByAscending:@"order"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *photos, NSError *error) {

        // CHANGE THIS TO PRESET COVER PHOTO INSTEAD OF FIRST PHOTO OF FIRST STOP
        Photo *firstPhoto = photos.firstObject;
        self.coverPhotoImageView.file = firstPhoto.image;
        [self.coverPhotoImageView loadInBackground];

        for (Photo *photo in photos) {
            [self.photos[photo.stop.objectId] addObject:photo];
        }
       // NSLog(@"self.stops has %lu items. self.photos has %lu items. reloading collectionview data.", self.stops.count, self.photos.count);
        [self.photosCollectionView reloadData];
    }];
}

- (void)setupViews {

    [self setupCollectionView];

    CGFloat labelMarginX = 8;
    CGFloat labelMarginY = 8;
    CGFloat labelWidth = self.view.bounds.size.width / 2 - labelMarginX;
    CGFloat labelHeight = 20;

    self.estimatedDistanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelMarginX, labelMarginY, labelWidth, labelHeight)];
    self.estimatedTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelMarginX, labelHeight + labelMarginY, labelWidth, labelHeight)];
    self.distanceFromCurrentLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth + labelMarginX , labelMarginY, labelWidth, labelHeight)];
    self.ratingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth + labelMarginX, labelHeight + labelMarginY, labelWidth, labelHeight)];

    self.estimatedDistanceLabel.text = [NSString stringWithFormat:@"Distance: %@", nil];
    self.estimatedTimeLabel.text = [NSString stringWithFormat:@"Estimated Time: %@", nil];
    self.distanceFromCurrentLocationLabel.text = [NSString stringWithFormat:@"From Current Location: %@", nil];
    self.ratingsLabel.text = [NSString stringWithFormat:@"Average rating: %@", nil];

    NSArray *labels = @[self.estimatedDistanceLabel, self.estimatedTimeLabel, self.distanceFromCurrentLocationLabel, self.ratingsLabel];

    for (UILabel *label in labels) {
        [label setFont:[UIFont systemFontOfSize:12]];
        //[label setTextColor:[UIColor whiteColor]];
    }

    CGFloat summaryWidth = self.view.bounds.size.width;
    CGFloat summaryHeight = self.tourDetailView.layer.bounds.size.height - (labelHeight*2 + labelMarginY);

    self.summaryTextView = [[SummaryTextView alloc] initWithFrame:CGRectMake(0, labelHeight*2 + labelMarginY, summaryWidth, summaryHeight)];
    //self.summaryTextView.text = @"Really super long tour description goes here.self.tourDetailView.layer.bounds.size.width";
    self.summaryTextView.text = self.tour.summary;
    self.summaryTextView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    self.summaryTextView.delegate = self;

    [self.tourDetailView addSubview:self.estimatedDistanceLabel];
    [self.tourDetailView addSubview:self.estimatedTimeLabel];
    [self.tourDetailView addSubview:self.distanceFromCurrentLocationLabel];
    [self.tourDetailView addSubview:self.ratingsLabel];
    [self.tourDetailView addSubview:self.summaryTextView];

    self.tourDetailView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.7];

    CGFloat addStopButtonWidth = self.view.layer.bounds.size.width / 6;
    NSLog(@"%f, %f.....%f, %f", self.mapView.layer.bounds.size.width, self.mapView.bounds.size.width, addStopButtonWidth, self.mapView.layer.bounds.size.width - addStopButtonWidth);


    self.addStopButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.layer.bounds.size.width - addStopButtonWidth, self.mapView.bounds.origin.y, addStopButtonWidth, self.mapView.layer.bounds.size.height)];
    [self.addStopButton setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:.5]];
    self.addStopButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.addStopButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.addStopButton setTitle:@"Add\n/Edit\nStops" forState:UIControlStateNormal];
    [self.mapView addSubview:self.addStopButton];

}

- (void)setupCollectionView {

    [self.photosCollectionView registerClass:[TourPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"PhotoCell"];

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];

    CGFloat cellWidth = self.photosCollectionView.layer.bounds.size.height;
    flowLayout.itemSize = CGSizeMake(cellWidth, self.photosCollectionView.layer.bounds.size.height);
    //NSLog(@"Cell width is %f", cellWidth);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 50;

    [self.photosCollectionView setCollectionViewLayout:flowLayout];
}

#pragma mark - UICollectionView dataSource/delegate methods

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    TourPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];

    Stop *stop = self.stops[indexPath.section];
    Photo *photo = self.photos[stop.objectId][indexPath.row];


    UIColor *sectionColor1 = [UIColor colorWithRed:19/255.0 green:157/255.0 blue:172/255.0 alpha:1.0];
    UIColor *sectionColor2 = [UIColor colorWithRed:177/255.0 green:243/255.0 blue:250/255.0 alpha:1.0];
    //NSLog(@"adding photo for stop %@", stop.title);
    cell.backgroundColor = indexPath.section % 2 ? sectionColor1 : sectionColor2;

    cell.imageView.file = photo.image;
    [cell.imageView loadInBackground];

    return cell;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    Stop *stop = self.stops[section];
    return [self.photos[stop.objectId] count];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.stops.count;
}

#pragma mark - MapKit methods

- (void)loadStopsOnMap {

    for (Stop *stop in self.stops) {

        StopPointAnnotation *stopPointAnnotation = [[StopPointAnnotation alloc] initWithStop:stop];
        [self.mapView addAnnotation:stopPointAnnotation];
    }
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];

    pin.userInteractionEnabled = YES;
    pin.canShowCallout = YES;

    return pin;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {

    StopPointAnnotation *annotation = view.annotation;
    Stop *stop = annotation.stop;

    NSLog(@"%@", stop.title);

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:[self.stops indexOfObject:stop]];
    NSLog(@"%@", indexPath);
    [self.photosCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
   // self.stopTitle.text = stop.title;
}

#pragma mark - UITextField Delegate methods

-(void)textFieldDidEndEditing:(UITextField *)textField {
    //[self.view endEditing:YES];
    self.tour.title = self.titleTextField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - SummaryTextView Delegate methods

-(void)textViewDidChange:(UITextView *)textView {
    self.tour.summary = textView.text;
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}
//-(BOOL)textViewShouldEndEditing:(UITextView *)textView {
//
//    return YES;
//}
@end




