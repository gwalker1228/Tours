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

static CGFloat tableCellHeight = 200;
static NSString *BuildTourStopsTableViewCellIdentifier = @"BuildTourStopsTableViewCell";
//static CGFloat tableCellHeight = 200;

@interface BuildTourStopsTableViewCell : UITableViewCell

@property float superviewWidth;
@property float superviewHeight;

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *summary;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size;

- (void)setTitle:(NSString *)title summary:(NSString *)summary;

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath;

@end

