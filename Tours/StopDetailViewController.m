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

static NSString *reuseIdentifier = @"PhotoCell";

@interface StopDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property NSArray *photos;

@end

@implementation StopDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setInitialCollectionViewLayout];

    BuildManager *buildManager = [BuildManager sharedBuildManager];
    Tour *tour = buildManager.tour;

    PFQuery *stopsQuery = [Stop query];
    [stopsQuery whereKey:@"tour" equalTo:tour];

    [stopsQuery findObjectsInBackgroundWithBlock:^(NSArray *stops, NSError *error) {

        self.stop = stops.firstObject;
        [self setup];
    }];

}

- (void)setup {

    self.titleLabel.text = self.stop.title;
    self.summaryLabel.text = self.stop.summary;

    PFQuery *query = [Photo query];
    [query whereKey:@"stop" equalTo:self.stop];
    [query orderByAscending:@"order"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *photos, NSError *error) {

        self.photos = photos;
        [self.collectionView reloadData];
    }];
}

- (void)setupMap {

    // Add annotation based on self.stop.location (look at BuildStopPreviewViewController)

    // Zoom map to close radius
}

- (void)setInitialCollectionViewLayout {

    NSLog(@"%@", NSStringFromSelector(_cmd));

    [self.collectionView registerClass:[StopPhotoCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];

    self.collectionView.backgroundColor = [UIColor darkGrayColor];
    self.collectionView.layer.borderColor = [UIColor blackColor].CGColor;
    self.collectionView.layer.borderWidth = 1.0;
    CGFloat collectionWidth = self.view.bounds.size.width / 3; //CGRectGetWidth(self.collectionView.bounds) / 3;

    NSLog(@"width: %f CGRect: %@", collectionWidth, NSStringFromCGRect(self.collectionView.bounds));

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

@end
