//
//  StopDetailViewController.m
//  Tours
//
//  Created by Adriana Jimenez Mangas on 6/22/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "StopDetailViewController.h"
#import "StopPhotoCollectionViewCell.h"
#import <MapKit/MapKit.h>


static NSString *reuseIdentifier = @"PhotoCell";

@interface StopDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation StopDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setInitialCollectionViewLayout];
}


- (void)setInitialCollectionViewLayout {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.collectionView registerClass:[StopPhotoCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    self.collectionView.backgroundColor = [UIColor darkGrayColor];
    self.collectionView.layer.borderColor = [UIColor blackColor].CGColor;
    self.collectionView.layer.borderWidth = 1.0;
    CGFloat collectionWidth = CGRectGetWidth(self.collectionView.bounds) / 3;
    NSLog(@"width: %f CGRect: %@", collectionWidth, NSStringFromCGRect(self.collectionView.bounds));

    /**** new size ****/
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(113, 113);
    [flowLayout setMinimumInteritemSpacing:1.0f];
    [flowLayout setMinimumLineSpacing:1.0f];
    [self.collectionView setCollectionViewLayout:flowLayout];

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 30;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    StopPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];

    return cell;
}

@end
