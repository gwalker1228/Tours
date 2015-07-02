//
//  RatingTableViewCell.m
//  RatingViewController
//
//  Created by Mark Porcella on 6/24/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "RatingTableViewCell.h"
#import "Review.h"

@interface RatingTableViewCell ()

@property UIButton *flagButton;

@end

@implementation RatingTableViewCell


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        CGRect rateViewFrame = CGRectMake(15, 5, 80, 20);
        self.rateView = [[RateView alloc] initWithFrame:rateViewFrame];
        self.rateView.editable = NO; // or no depending on if we're in a comment or just viewing
        self.rateView.rating = self.review ? self.review.rating : 0;
        [self addSubview:self.rateView];

        self.flagButton = [[UIButton alloc] initWithFrame:CGRectZero];

        [self.flagButton setTitle:@"Flag as inappropriate" forState:UIControlStateNormal];
        [self.flagButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];

        self.flagButton.titleLabel.font = [UIFont systemFontOfSize:14];

        [self.flagButton addTarget:self action:@selector(onFlagButtonPressed) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:self.flagButton];

    }
    return self;
}

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

    CGFloat flagButtonWidth = 150;

    self.flagButton.frame = CGRectMake(self.frame.size.width - flagButtonWidth - 15, 5, flagButtonWidth, 20);

}

-(void)onFlagButtonPressed {

    [self.delegate ratingTableViewCell:self didPressFlagButtonForReview:self.review];
}

-(void)clearSubviews {
    [self.flagButton removeFromSuperview];
}

-(void)showFlagButton {
    [self clearSubviews];
    [self addSubview:self.flagButton];
}

@end
