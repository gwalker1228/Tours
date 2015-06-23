//
//  TourDetailViewController.m
//  Tours
//
//  Created by Gretchen Walker on 6/22/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "TourDetailViewController.h"
#import "StopPointAnnotation.h"
#import "TourPhotoCollectionViewCell.h"
#import "Stop.h"
#import "Photo.h"
#import <MapKit/MapKit.h>
#import <ParseUI/ParseUI.h>

@interface TourDetailViewController () <MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet PFImageView *coverPhotoImageView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
//@property (weak, nonatomic) IBOutlet UILabel *stopTitle;
@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;
@property (weak, nonatomic) IBOutlet UIView *tourDetailView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;

@property NSArray *stops;
@property NSMutableDictionary *photos;

@end

@implementation TourDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.titleTextField.text = self.tour.title ? : @"New Tour";
    self.tour.title = self.titleTextField.text;
    [self setupCollectionView];
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

- (void)setupCollectionView {

    [self.photosCollectionView registerClass:[TourPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"PhotoCell"];

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];

    CGFloat cellWidth = self.photosCollectionView.layer.bounds.size.height - 16;
    flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth);
    //NSLog(@"Cell width is %f", cellWidth);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8);
    //flowLayout.minimumLineSpacing = 15;
    flowLayout.minimumInteritemSpacing = 0;

    [self.photosCollectionView setCollectionViewLayout:flowLayout];
}

#pragma mark - UICollectionView dataSource/delegate methods

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    TourPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];

    Stop *stop = self.stops[indexPath.section];
    Photo *photo = self.photos[stop.objectId][indexPath.row];

    //NSLog(@"adding photo for stop %@", stop.title);
    cell.backgroundColor = indexPath.section % 2 ? [UIColor redColor] : [UIColor blueColor];

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


-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {

    StopPointAnnotation *annotation = view.annotation;
    Stop *stop = annotation.stop;

    NSLog(@"%@", stop.title);
   // self.stopTitle.text = stop.title;
}

#pragma mark - UITextField Delegate methods

-(void)textFieldDidEndEditing:(UITextField *)textField {
    //[self.view endEditing:YES];
    self.tour.title = self.titleTextField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}

@end




