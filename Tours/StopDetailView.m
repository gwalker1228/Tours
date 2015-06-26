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

static CGFloat verticalSpaceInterval = 0.0;
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

    self.backgroundColor = [UIColor colorWithRed:252/255.0 green:255/255.0 blue:245/255.0 alpha:1.0];

    return self;
}

- (void)createLabels {

    CGFloat labelWidth = self.parentFrame.size.width - (rightMarginIndent + leftMarginIndent);
    CGFloat labelHeight = self.parentFrame.size.height/6;

    CGFloat titleLabelX = rightMarginIndent;
    CGFloat titleLabelY = verticalSpaceInterval;

    CGFloat descriptionLabelX = titleLabelX;
    CGFloat descriptionLabelY = titleLabelY + labelHeight + verticalSpaceInterval;

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, labelWidth, labelHeight)];
    self.summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(descriptionLabelX, descriptionLabelY, labelWidth, labelHeight)];

//    self.titleLabel.backgroundColor = [UIColor blueColor];
//    self.summaryLabel.backgroundColor = [UIColor greenColor];

    self.titleLabel.textColor = [UIColor colorWithRed:25/255.0 green:52/255.0 blue:65/255.0 alpha:1.0];
    self.summaryLabel.textColor = [UIColor colorWithRed:25/255.0 green:52/255.0 blue:65/255.0 alpha:1.0];

    [self addSubview:self.titleLabel];
    [self addSubview:self.summaryLabel];
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
