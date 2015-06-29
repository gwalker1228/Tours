//
//  PhotoPopup.m
//  Tours
//
//  Created by Gretchen Walker on 6/29/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "PhotoPopup.h"

@interface PhotoPopup ()

@property UIImageView *imageView;
@property UIView *blackView;
//@property UIView *superview;

@end

@implementation PhotoPopup


+ (void)popupWithImage:(UIImage *)image inView:(UIView *)view {

    PhotoPopup *popup = [[PhotoPopup alloc] initWithFrame:view.frame];

    //self = [super initWithFrame:view.frame];
    popup.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    popup.imageView.image = image;
    popup.imageView.frame = CGRectMake(view.center.x, view.center.y, 0, 0);

    CGFloat imageSize = view.bounds.size.width;
    CGFloat originx = view.center.x - (imageSize / 2);
    CGFloat originy = view.center.y - (imageSize / 2);

    popup.blackView = [[UIView alloc] initWithFrame:view.bounds];
    popup.blackView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    [popup addSubview:popup.blackView];
    [view addSubview:popup];
    [UIView animateWithDuration:.5 animations:^{

        [popup addSubview:popup.imageView];
        popup.imageView.frame = CGRectMake(originx, originy, imageSize, imageSize);
        [popup bringSubviewToFront:popup.imageView];

    } completion:^(BOOL finished) {

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:popup action:@selector(onViewTapped)];

        [popup.imageView addGestureRecognizer:tap];
        [popup.blackView addGestureRecognizer:tap];
    }];

   // return self;
}

- (void)onViewTapped {

    [UIView animateWithDuration:0.1 animations:^{

        self.imageView.frame = CGRectMake(self.superview.center.x, self.superview.center.y, 1, 1);
        self.blackView.frame = CGRectMake(self.superview.center.x, self.superview.center.y, 1, 1);

    } completion:^(BOOL finished) {

        [self.imageView removeFromSuperview];
        [self.blackView removeFromSuperview];
        [self removeFromSuperview];
    }];
}



//- (instancetype)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//
//        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
//        self.imageView.image = cell.imageView.image;
//        self.imageView.frame = CGRectMake(self.view.center.x, self.view.center.y, 0, 0);
//
//        CGFloat imageSize = self.view.bounds.size.width;
//        CGFloat originx = self.view.center.x - (imageSize / 2);
//        CGFloat originy = self.view.center.y - (imageSize / 2);
//
//        self.blackView = [[UIView alloc] initWithFrame:self.view.bounds];
//        self.blackView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
//        [self.view addSubview:self.blackView];
//
//
//    }
//    return self;
//}

@end
