//
//  BuildTourStopsTableViewCell.h
//  Tours
//
//  Created by Gretchen Walker on 6/16/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StopDetailView.h"
@class IndexedPhotoCollectionView;

//static CGFloat tableCellHeight = 200;

@interface BuildTourStopsTableViewCell : UITableViewCell


//@property (nonatomic, strong) UILabel *titleLabel;
//@property (nonatomic, strong) UILabel *descriptionLabel;
//@property (nonatomic, strong) IndexedPhotoCollectionView *collectionView;

- (void)setTitle:(NSString *)title summary:(NSString *)summary;

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath;

@end

