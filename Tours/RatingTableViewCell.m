//
//  RatingTableViewCell.m
//  RatingViewController
//
//  Created by Mark Porcella on 6/24/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "RatingTableViewCell.h"

@implementation RatingTableViewCell


- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];

    self.contentView.frame = self.bounds;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // (2)
    [self.contentView updateConstraintsIfNeeded];
    [self.contentView layoutIfNeeded];

    // (3)
    self.reviewSummary.preferredMaxLayoutWidth = CGRectGetWidth(self.reviewSummary.frame);
}


@end
