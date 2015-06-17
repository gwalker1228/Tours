//
//  BuildTourStopsTableViewCell.m
//  Tours
//
//  Created by Gretchen Walker on 6/16/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BuildTourStopsTableViewCell.h"
#import "IndexedPhotoCollectionView.h"
#import "IndexedPhotoCollectionViewCell.h"

//static CGFloat verticalSpaceInterval = 8.0;
//static CGFloat rightMarginIndent = 8.0;
//static CGFloat leftMarginIndent = 8.0;

@interface BuildTourStopsTableViewCell ()

@property (nonatomic) StopDetailView *mainView;

@end

@implementation BuildTourStopsTableViewCell

//- (id)initWithCoder:(NSCoder *)aDecoder {
//    self = [super initWithCoder:aDecoder];
//
////    [self createLabels];
////    [self createCollectionView];
////    self.mainView = [[StopDetailView alloc] initWithCoder:aDecoder];
//
//   // self.contentView = self.mainView;
//    return self;
//}

-(void)layoutSubviews {
    [super layoutSubviews];

    self.mainView = [[StopDetailView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.mainView];
//    CGRect bounds = self.contentView.bounds;
//    CGFloat collectionViewY = self.descriptionLabel.layer.frame.origin.y + self.descriptionLabel.layer.frame.size.height;
//    self.collectionView.frame = CGRectMake(0, collectionViewY, bounds.size.width, bounds.size.height - collectionViewY);
}

////-(instancetype)initWithFrame:(CGRect)frame {
////
////}
//
//- (void)createLabels {
//
//    //CGSize superviewFrameSize = self.contentView.frame.size;
//
////    CGFloat labelWidth = superviewFrameSize.width - (rightMarginIndent + leftMarginIndent);
//    CGFloat labelWidth = 300;
//    CGFloat labelHeight = 30;
//
//    CGFloat titleLabelX = rightMarginIndent;
//    CGFloat titleLabelY = leftMarginIndent;
//
//    CGFloat descriptionLabelX = titleLabelX;
//    CGFloat descriptionLabelY = titleLabelY + labelHeight + verticalSpaceInterval;
//
//    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, labelWidth, labelHeight)];
//    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(descriptionLabelX, descriptionLabelY, labelWidth, labelHeight)];
//
//    self.titleLabel.backgroundColor = [UIColor blueColor];
//    self.descriptionLabel.backgroundColor = [UIColor greenColor];
//
//    [self.contentView addSubview:self.titleLabel];
//    [self.contentView addSubview:self.descriptionLabel];
//}
//
//- (void)createCollectionView {
//
//   // CGSize superviewFrameSize = self.contentView.layer.frame.size;
//
//    //CGFloat collectionViewX = rightMarginIndent;
//    CGFloat collectionViewY = self.descriptionLabel.layer.frame.origin.y + self.descriptionLabel.layer.frame.size.height + verticalSpaceInterval;
//
//    CGFloat cellWidth = (tableCellHeight - verticalSpaceInterval) - collectionViewY - 2;
//
//    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
//    flowLayout.sectionInset = UIEdgeInsetsMake(verticalSpaceInterval, 8.0, 8.0, 8.0);
//
////    flowLayout.itemSize = CGSizeMake(150, 150);
//    flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth);
//    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//    [flowLayout setMinimumInteritemSpacing:1.0f];
//    [flowLayout setMinimumLineSpacing:1.0f];
//
//    self.collectionView = [[IndexedPhotoCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
//    [self.collectionView registerClass:[IndexedPhotoCollectionViewCell class] forCellWithReuseIdentifier:indexedPhotoCollectionViewCellID];
//    self.collectionView.backgroundColor = [UIColor whiteColor];
//    self.collectionView.showsHorizontalScrollIndicator = NO;
//
////    self.collectionView
//
//    [self.contentView addSubview:self.collectionView];
//}
//



- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath {

    [self.mainView setCollectionViewDataSourceDelegate:dataSourceDelegate indexPath:indexPath];
//    self.mainView.collectionView.dataSource = dataSourceDelegate;
//    self.mainView.collectionView.delegate = dataSourceDelegate;
//    self.mainView.collectionView.indexPath = indexPath;
//
//    [self.mainView.collectionView reloadData];
}


- (void)setTitle:(NSString *)title summary:(NSString *)summary {
    self.mainView.titleLabel.text = title;
    self.mainView.summaryLabel.text = summary;
    [self.mainView reloadInputViews];
}

@end
