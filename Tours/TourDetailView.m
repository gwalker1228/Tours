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

    return self;
}

- (void)createLabels {

    CGFloat labelWidth = self.parentFrame.size.width - (rightMarginIndent + leftMarginIndent);
    CGFloat labelHeight = self.parentFrame.size.height/6;

    CGFloat detailLabelWidth = labelWidth / 2;
    CGFloat detailLabelHeight = labelHeight / 2.5 + 4;

    CGFloat titleLabelX = rightMarginIndent;
    CGFloat titleLabelY = verticalSpaceInterval;

    CGFloat totalDistanceLabelX = titleLabelX;
    CGFloat totalDistanceLabelY = titleLabelY + labelHeight + verticalSpaceInterval;

    CGFloat estimatedTimeLabelX = titleLabelX;
    CGFloat estimatedTimeLabelY = totalDistanceLabelY + detailLabelHeight + verticalSpaceInterval;

    CGFloat summaryLabelX = titleLabelX;
    CGFloat summaryLabelY = estimatedTimeLabelY + detailLabelHeight + verticalSpaceInterval;


    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, labelWidth, labelHeight)];
    self.summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(summaryLabelX, summaryLabelY, labelWidth, labelHeight)];
    self.totalDistanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(totalDistanceLabelX, totalDistanceLabelY, detailLabelWidth, detailLabelHeight)];
    self.estimatedTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(estimatedTimeLabelX, estimatedTimeLabelY, detailLabelWidth, detailLabelHeight)];
    //    self.titleLabel.backgroundColor = [UIColor blueColor];
    //    self.summaryLabel.backgroundColor = [UIColor greenColor];

    self.totalDistanceLabel.font = [UIFont systemFontOfSize:14.0];
    self.estimatedTimeLabel.font = [UIFont systemFontOfSize:14.0];

    [self addSubview:self.titleLabel];
    [self addSubview:self.summaryLabel];
    [self addSubview:self.totalDistanceLabel];
    [self addSubview:self.estimatedTimeLabel];
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



