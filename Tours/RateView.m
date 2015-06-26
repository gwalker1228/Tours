//
//  RatingStar.m
//  Tours
//
//  Created by Mark Porcella on 6/23/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "RateView.h"

@implementation RateView


- (void)baseInit {

    self.notSelectedImage = [UIImage imageNamed:@"starNotSelected"];
    self.halfSelectedImage = [UIImage imageNamed:@"starHalfSelected"];
    self.fullSelectedImage = [UIImage imageNamed:@"starSelected"];

    self.rating = 0;
    self.editable = NO;

    self.maxRating = 5;
    self.midMargin = 5;
    self.leftMargin = 0;
    self.minImageSize = CGSizeMake(5, 5);
    self.delegate = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (void)refresh {
    for(int i = 0; i < self.imageViews.count; ++i) {

        UIImageView *imageView = [self.imageViews objectAtIndex:i];
        if (self.rating >= i+1) {
            imageView.image = self.fullSelectedImage;
        } else if (self.rating > i) {
            imageView.image = self.halfSelectedImage;
        } else {
            imageView.image = self.notSelectedImage;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.notSelectedImage == nil) return;

    float desiredImageWidth = (self.frame.size.width - (self.leftMargin*2) - (self.midMargin*self.imageViews.count)) / self.imageViews.count;
    float imageWidth = MAX(self.minImageSize.width, desiredImageWidth);
    float imageHeight = MAX(self.minImageSize.height, self.frame.size.height);

    for (int i = 0; i < self.imageViews.count; ++i) {

        UIImageView *imageView = [self.imageViews objectAtIndex:i];
        CGRect imageFrame = CGRectMake(self.leftMargin + i*(self.midMargin+imageWidth), 0, imageWidth, imageHeight);
        imageView.frame = imageFrame;

    }

}

- (void)setMaxRating:(int)maxRating {
    _maxRating = maxRating;

    self.imageViews = [[NSMutableArray alloc] init];

    // Remove old image views
    for(int i = 0; i < self.imageViews.count; ++i) {
        UIImageView *imageView = (UIImageView *) [self.imageViews objectAtIndex:i];
        [imageView removeFromSuperview];
    }
    [self.imageViews removeAllObjects];

    // Add new image views
    for(int i = 0; i < maxRating; ++i) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.imageViews addObject:imageView];
        [self addSubview:imageView];
    }




    // Relayout and refresh
    [self setNeedsLayout];
    [self refresh];
}

- (void)setNotSelectedImage:(UIImage *)image {
    _notSelectedImage = image;
    [self refresh];
}

- (void)setHalfSelectedImage:(UIImage *)image {
    _halfSelectedImage = image;
    [self refresh];
}

- (void)setFullSelectedImage:(UIImage *)image {
    _fullSelectedImage = image;
    [self refresh];
}

- (void)setRating:(float)rating {
    _rating = rating;
    [self refresh];
}

- (void)handleTouchAtLocation:(CGPoint)touchLocation {
    if (!self.editable) return;

    int newRating = 0;
    for(int i = (int)self.imageViews.count - 1; i >= 0; i--) {
        UIImageView *imageView = [self.imageViews objectAtIndex:i];
        if (touchLocation.x > imageView.frame.origin.x) {
            newRating = i+1;
            break;
        }
    }

    self.rating = newRating;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    [self handleTouchAtLocation:touchLocation];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    [self handleTouchAtLocation:touchLocation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.delegate rateView:self ratingDidChange:self.rating];
}



@end

//ADD TO IMPLEMENTING VIEW CONTROLLER

//- (void)viewDidLoad {
//    [super viewDidLoad];
//
//    CGRect rateViewFrame = CGRectMake(100, 200, 200, 100);
//    self.rateView = [[RateView alloc] initWithFrame:rateViewFrame];
//    [self.view addSubview:self.rateView];
//    self.rateView.rating = 2; // set from Parse data
//    self.rateView.editable = YES; // or no depending on if we're in a comment or just viewing
//    self.rateView.delegate = self;
//
//}
//
//- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating {
//    self.statusLabel.text = [NSString stringWithFormat:@"Rating: %f", rating];
//}
