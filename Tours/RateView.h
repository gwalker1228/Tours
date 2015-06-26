//
//  RatingStar.h
//  Tours
//
//  Created by Mark Porcella on 6/23/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//


#import <UIKit/UIKit.h>

@class RateView;

@protocol RateViewDelegate

- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating;

@end

@interface RateView : UIView

@property (strong, nonatomic) UIImage *notSelectedImage;
@property (strong, nonatomic) UIImage *halfSelectedImage;
@property (strong, nonatomic) UIImage *fullSelectedImage;
@property (assign, nonatomic) float rating;
@property (assign) BOOL editable;
@property (strong) NSMutableArray * imageViews;
@property (assign, nonatomic) int maxRating;
@property (assign) int midMargin;
@property (assign) int leftMargin;
@property (assign) CGSize minImageSize;
@property (assign) id <RateViewDelegate> delegate;

@end
