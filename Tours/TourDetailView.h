//
//  TourDetailView.h
//  Tours
//
//  Created by Gretchen Walker on 6/25/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IndexedPhotoCollectionView;
@class RateView;

@interface TourDetailView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *summaryLabel;
@property (nonatomic, strong) UILabel *totalDistanceLabel;
@property (nonatomic, strong) UILabel *estimatedTimeLabel;
@property (nonatomic, strong) UILabel *distanceFromCurrentLocationLabel;
@property (nonatomic, strong) UILabel *ratingLabel;
@property (nonatomic, strong) RateView *ratingView;

@property (nonatomic, strong) IndexedPhotoCollectionView *collectionView;


- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath;

@end