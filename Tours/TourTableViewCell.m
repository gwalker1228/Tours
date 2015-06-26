//
//  TourTableViewCell.m
//  Tours
//
//  Created by Mark Porcella on 6/17/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "TourTableViewCell.h"
#import "IndexedPhotoCollectionView.h"
#import "IndexedPhotoCollectionViewCell.h"

@interface TourTableViewCell ()

@property (nonatomic) TourDetailView *mainView;

@end

@implementation TourTableViewCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    self.superviewWidth = size.width;
    self.superviewHeight = size.height;

    self.mainView = [[TourDetailView alloc] initWithFrame:CGRectMake(0, 0, self.superviewWidth, self.superviewHeight)];
    [self addSubview:self.mainView];
    //   [self.contentView addSubview:self.mainView];
    [self bringSubviewToFront:self.mainView];

    return self;
}

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath {

    [self.mainView setCollectionViewDataSourceDelegate:dataSourceDelegate indexPath:indexPath];
}


- (void)setTitle:(NSString *)title {

    _title = title;
    self.mainView.titleLabel.text = title;
}

- (void)setSummary:(NSString *)summary {

    _summary = summary;
    self.mainView.summaryLabel.text = summary;
}

- (void)setTotalDistance:(float)totalDistance {
    _totalDistance = totalDistance;
    self.mainView.totalDistanceLabel.text = [NSString stringWithFormat:@"Total Distance: %.2g mi", totalDistance];
}

- (void)setEstimatedTime:(float)estimatedTime {
    _estimatedTime = estimatedTime;
    self.mainView.estimatedTimeLabel.text = [NSString stringWithFormat:@"Estimated Time: %g min", estimatedTime];
}

- (void)setTitle:(NSString *)title summary:(NSString *)summary {
    self.mainView.titleLabel.text = title;
    self.mainView.summaryLabel.text = summary;
    [self.mainView reloadInputViews];
}

@end
