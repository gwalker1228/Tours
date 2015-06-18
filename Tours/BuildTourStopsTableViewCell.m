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


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    self.superviewWidth = size.width;
    self.superviewHeight = size.height;

    self.mainView = [[StopDetailView alloc] initWithFrame:CGRectMake(0, 0, self.superviewWidth, self.superviewHeight)];
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


- (void)setTitle:(NSString *)title summary:(NSString *)summary {
    self.mainView.titleLabel.text = title;
    self.mainView.summaryLabel.text = summary;
    [self.mainView reloadInputViews];
}

@end
