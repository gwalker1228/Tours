//
//  StopDetailView.m
//  Tours
//
//  Created by Gretchen Walker on 6/17/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "StopDetailView.h"
#import "IndexedPhotoCollectionView.h"
#import "IndexedPhotoCollectionViewCell.h"

static CGFloat verticalSpaceInterval = 8.0;
static CGFloat rightMarginIndent = 8.0;
static CGFloat leftMarginIndent = 8.0;

@interface StopDetailView ()

@property CGRect parentFrame;

@end

@implementation StopDetailView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.parentFrame = frame;

    [self createLabels];
    [self createCollectionView];

    return self;
}

- (void)createLabels {

    CGFloat labelWidth = self.parentFrame.size.width - verticalSpaceInterval * 2;
    CGFloat labelHeight = 30;

    CGFloat titleLabelX = rightMarginIndent;
    CGFloat titleLabelY = leftMarginIndent;

    CGFloat descriptionLabelX = titleLabelX;
    CGFloat descriptionLabelY = titleLabelY + labelHeight + verticalSpaceInterval;

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, labelWidth, labelHeight)];
    self.summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(descriptionLabelX, descriptionLabelY, labelWidth, labelHeight)];

    self.titleLabel.backgroundColor = [UIColor blueColor];
    self.summaryLabel.backgroundColor = [UIColor greenColor];

    [self addSubview:self.titleLabel];
    [self addSubview:self.summaryLabel];
}

- (void)createCollectionView {

    CGFloat collectionViewY = self.summaryLabel.layer.frame.origin.y + self.summaryLabel.layer.frame.size.height + verticalSpaceInterval;
    CGFloat cellWidth = (self.parentFrame.size.height - verticalSpaceInterval) - collectionViewY - 2;

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];

    flowLayout.sectionInset = UIEdgeInsetsMake(verticalSpaceInterval, 8.0, 8.0, 8.0);
    flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [flowLayout setMinimumInteritemSpacing:1.0f];
    [flowLayout setMinimumLineSpacing:1.0f];

    self.collectionView = [[IndexedPhotoCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [self.collectionView registerClass:[IndexedPhotoCollectionViewCell class] forCellWithReuseIdentifier:indexedPhotoCollectionViewCellID];
    self.collectionView.backgroundColor = [UIColor whiteColor];
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
