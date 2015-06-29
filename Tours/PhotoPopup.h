//
//  PhotoPopup.h
//  Tours
//
//  Created by Gretchen Walker on 6/29/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Photo;

@interface PhotoPopup : UIView

+ (void)popupWithImage:(UIImage *)image inView:(UIView *)view;
+ (void)popupWithImage:(UIImage *)image photo:(Photo *)photo inView:(UIView *)view;

@end
