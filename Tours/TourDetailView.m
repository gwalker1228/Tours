//
//  TourDetailView.m
//  Tours
//
//  Created by Gretchen Walker on 6/25/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "TourDetailView.h"
#import "IndexedPhotoCollectionView.h"
#import "IndexedPhotoCollectionViewCell.h"
#import "RateView.h"

static CGFloat verticalSpaceInterval = 0.0;
static CGFloat rightMarginIndent = 8.0;
static CGFloat leftMarginIndent = 8.0;

@interface TourDetailView ()

@property CGRect parentFrame;

@end


@implementation TourDetailView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.parentFrame = frame;

    [self createLabels];
    [self createCollectionView];

    self.backgroundColor = [UIColor colorWithRed:252/255.0 green:255/255.0 blue:245/255.0 alpha:1.0];

    return self;
}

- (void)createLabels {

    CGFloat labelWidth = self.parentFrame.size.width - (rightMarginIndent + leftMarginIndent);
    CGFloat labelHeight = self.parentFrame.size.height/6;

    CGFloat detailLabelWidth = labelWidth / 2 - rightMarginIndent;
    CGFloat detailLabelHeight = labelHeight / 2.5 + 4;

    CGFloat titleLabelX = rightMarginIndent;
    CGFloat titleLabelY = verticalSpaceInterval;

    CGFloat totalDistanceLabelX = titleLabelX;
    CGFloat totalDistanceLabelY = titleLabelY + labelHeight + verticalSpaceInterval;

    CGFloat estimatedTimeLabelX = titleLabelX;
    CGFloat estimatedTimeLabelY = totalDistanceLabelY + detailLabelHeight + verticalSpaceInterval;

    CGFloat summaryLabelX = titleLabelX;
    CGFloat summaryLabelY = estimatedTimeLabelY + detailLabelHeight + verticalSpaceInterval;

    CGFloat distanceFromCurrentLocationLabelX = totalDistanceLabelX + detailLabelWidth;
    CGFloat distanceFromCurrentLocationLabelY = totalDistanceLabelY;

    CGFloat ratingLabelX = estimatedTimeLabelX + detailLabelWidth;
    CGFloat ratingLabelY = estimatedTimeLabelY;
    CGFloat ratingLabelWidth = detailLabelWidth / 2;

    CGFloat ratingViewX = ratingLabelX + ratingLabelWidth;
    CGFloat ratingViewY = ratingLabelY;
    CGFloat ratingViewWidth = detailLabelWidth - ratingLabelWidth;

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, labelWidth - labelHeight, labelHeight)];
    self.summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(summaryLabelX, summaryLabelY, labelWidth, labelHeight)];
    self.totalDistanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(totalDistanceLabelX, totalDistanceLabelY, detailLabelWidth, detailLabelHeight)];
    self.estimatedTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(estimatedTimeLabelX, estimatedTimeLabelY, detailLabelWidth, detailLabelHeight)];
    self.distanceFromCurrentLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(distanceFromCurrentLocationLabelX, distanceFromCurrentLocationLabelY, detailLabelWidth, detailLabelHeight)];
    self.ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(ratingLabelX, ratingLabelY, ratingLabelWidth, detailLabelHeight)];
    self.ratingView = [[RateView alloc] initWithFrame:CGRectMake(ratingViewX, ratingViewY, ratingViewWidth, detailLabelHeight)];

    self.ratingView.editable = NO;

    NSArray *labels = @[self.titleLabel, self.summaryLabel, self.totalDistanceLabel, self.estimatedTimeLabel, self.distanceFromCurrentLocationLabel, self.ratingLabel];

    UIColor *textColor = [UIColor colorWithRed:25/255.0 green:52/255.0 blue:65/255.0 alpha:1.0];

    for (UILabel *label in labels) {
        label.textColor = textColor;
        [self addSubview:label];
    }
    [self addSubview:self.ratingView];

    self.titleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:25];
    self.summaryLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:18];

    NSArray *smallLabels = @[self.totalDistanceLabel, self.estimatedTimeLabel, self.distanceFromCurrentLocationLabel, self.ratingLabel];
    for (UILabel *label in smallLabels) {
        label.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:14];
    }
}

- (void)createCollectionView {

    CGFloat collectionViewY = self.summaryLabel.layer.frame.origin.y + self.summaryLabel.layer.frame.size.height;
    CGFloat cellWidth = (self.parentFrame.size.height - verticalSpaceInterval) - collectionViewY - 2;

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];

    flowLayout.sectionInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [flowLayout setMinimumInteritemSpacing:1.0f];
    [flowLayout setMinimumLineSpacing:1.0f];

    self.collectionView = [[IndexedPhotoCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [self.collectionView registerClass:[IndexedPhotoCollectionViewCell class] forCellWithReuseIdentifier:indexedPhotoCollectionViewCellID];
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;

    [self addSubview:self.collectionView];
}

-(void)layoutSubviews {
    [super layoutSubviews];

    CGFloat collectionViewY = self.summaryLabel.layer.frame.origin.y + self.summaryLabel.layer.frame.size.height;
    self.collectionView.frame = CGRectMake(0, collectionViewY, self.parentFrame.size.width, self.parentFrame.size.height - collectionViewY);
}


- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath {

    self.collectionView.dataSource = dataSourceDelegate;
    self.collectionView.delegate = dataSourceDelegate;
    self.collectionView.indexPath = indexPath;
    
    [self.collectionView reloadData];
}


@end



