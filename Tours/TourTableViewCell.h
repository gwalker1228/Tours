//
//  TourTableViewCell.h
//  Tours
//
//  Created by Mark Porcella on 6/17/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TourDetailView.h"

@class IndexedPhotoCollectionView;


static CGFloat tableCellHeight = 200;
static NSString *TourTableViewCellIdentifier = @"TourTableViewCell";
//static CGFloat tableCellHeight = 200;

@interface TourTableViewCell : UITableViewCell

@property float superviewWidth;
@property float superviewHeight;

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *summary;
@property (nonatomic) float totalDistance;
@property (nonatomic) float estimatedTime;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size;

- (void)setTitle:(NSString *)title summary:(NSString *)summary;

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath;

@end
