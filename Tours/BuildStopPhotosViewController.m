//
//  BuildStopPhotosViewController.m
//  Tours
//
//  Created by Mark Porcella on 6/14/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BuildStopPhotosViewController.h"
#import <UIKit/UIKit.h>

@interface BuildStopPhotosViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation BuildStopPhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {


        
    } else {


    }
}


//- (void) showPhotoLibraryPikcerController {
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.delegate = self;
//    picker.allowsEditing = YES;
//    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    [self presentViewController:picker animated:YES completion:nil];
//
//}
//
//- (void) showCameraPickerController {
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.delegate = self;
//    picker.allowsEditing = YES;
//    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    [self presentViewController:picker animated:YES completion:nil];
//}


@end
