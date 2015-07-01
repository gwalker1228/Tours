//
//  PhotoPopup.h
//  Tours
//
//  Created by Gretchen Walker on 6/29/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Photo;
@class PhotoPopup;

@protocol PhotoPopupDelegate <NSObject>

-(void)photoPopup:(PhotoPopup *)photoPopup editPhotoButtonPressed:(Photo *)photo;

@optional

-(void)photoPopup:(PhotoPopup *)photoPopup viewDidAppear:(Photo *)photo;
-(void)photoPopup:(PhotoPopup *)photoPopup viewDidDisappear:(Photo *)photo;

@end

@interface PhotoPopup : UIView

@property id<PhotoPopupDelegate> delegate;

+ (void)popupWithImage:(UIImage *)image inView:(UIView *)view;
+ (void)popupWithImage:(UIImage *)image photo:(Photo *)photo inView:(UIView *)view editable:(BOOL)editable delegate:(id<PhotoPopupDelegate>)delegate;
- (void)reloadViews;

@end
