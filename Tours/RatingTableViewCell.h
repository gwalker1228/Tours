//
//  RatingTableViewCell.h
//  RatingViewController
//
//  Created by Mark Porcella on 6/24/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RateView.h"

@interface RatingTableViewCell : UITableViewCell

@property RateView *rateView;


@property (weak, nonatomic) IBOutlet UILabel *reviewSummary;

@end

