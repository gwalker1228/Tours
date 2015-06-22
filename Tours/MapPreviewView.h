//
//  MapPreviewView.h
//  Tours
//
//  Created by Mark Porcella on 6/20/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//
#import <UIKit/UIKit.h>

@class IndexedPhotoCollectionView;

@interface MapPreviewView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *summaryLabel;
@property (nonatomic, strong) IndexedPhotoCollectionView *collectionView;

-(void) setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate;

@end
