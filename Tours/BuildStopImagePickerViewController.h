//
//  ImagePickerViewController.h
//  Tours
//
//  Created by Mark Porcella on 6/15/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Stop;
@class Photo;

@interface BuildStopImagePickerViewController : UIViewController

@property NSString *initialView;
@property NSNumber *orderNumber;
@property Stop *stop;
@property Photo *photo;

@end
