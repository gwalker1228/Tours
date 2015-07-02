//
//  RatingTableViewCell.h
//  RatingViewController
//
//  Created by Mark Porcella on 6/24/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RateView.h"

@class Review;
@class RatingTableViewCell;

@protocol RatingTableViewCellDelegate <NSObject>

-(void)ratingTableViewCell:(RatingTableViewCell *)tableViewCell didPressFlagButtonForReview:(Review *)review;

@end

@interface RatingTableViewCell : UITableViewCell

@property id<RatingTableViewCellDelegate> delegate;
@property RateView *rateView;
@property Review *review;

@property (weak, nonatomic) IBOutlet UILabel *reviewSummary;


-(void)clearSubviews;
-(void)showFlagButton;

@end



