//
//  PhotoPopup.m
//  Tours
//
//  Created by Gretchen Walker on 6/29/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "PhotoPopup.h"
#import "Photo.h"

@interface PhotoPopup ()

@property UIImageView *imageView;
@property UIView *blackView;
@property Photo *photo;

@end

@implementation PhotoPopup


+ (void)popupWithImage:(UIImage *)image inView:(UIView *)view {

    PhotoPopup *popup = [[PhotoPopup alloc] initWithFrame:view.frame];

    popup.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    popup.imageView.image = image;
    popup.imageView.frame = CGRectMake(view.center.x, view.center.y, 0, 0);

    CGFloat imageWidth = view.bounds.size.width;
    CGFloat originx = view.center.x - (imageWidth / 2);
    CGFloat originy = view.center.y - (imageWidth / 2);

    popup.blackView = [[UIView alloc] initWithFrame:view.bounds];
    popup.blackView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];

    [popup addSubview:popup.blackView];
    [view addSubview:popup];

    [UIView animateWithDuration:.5 animations:^{

        [popup addSubview:popup.imageView];
        popup.imageView.frame = CGRectMake(originx, originy, imageWidth, imageWidth);
        [popup bringSubviewToFront:popup.imageView];

    } completion:^(BOOL finished) {

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:popup action:@selector(onViewTapped)];

        [popup.imageView addGestureRecognizer:tap];
        [popup.blackView addGestureRecognizer:tap];
    }];
}

+ (void)popupWithImage:(UIImage *)image photo:(Photo *)photo inView:(UIView *)view {

    PhotoPopup *popup = [[PhotoPopup alloc] initWithFrame:view.frame];

    popup.photo = photo;

    popup.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    popup.imageView.image = image;
    popup.imageView.frame = CGRectMake(view.center.x, view.center.y, 0, 0);

    CGFloat imageWidth = view.bounds.size.width;
    CGFloat originx = view.center.x - (imageWidth / 2);
    CGFloat originy = view.center.y - (imageWidth / 2);

    popup.blackView = [[UIView alloc] initWithFrame:view.bounds];
    popup.blackView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];

    [popup addSubview:popup.blackView];
    [view addSubview:popup];

    [UIView animateWithDuration:.5 animations:^{

        [popup addSubview:popup.imageView];
        popup.imageView.frame = CGRectMake(originx, originy, imageWidth, imageWidth);
        [popup bringSubviewToFront:popup.imageView];

    } completion:^(BOOL finished) {

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:popup action:@selector(onViewTapped)];

        [popup.imageView addGestureRecognizer:tap];
        [popup.blackView addGestureRecognizer:tap];
    }];
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

@end
