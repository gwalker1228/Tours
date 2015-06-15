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



- (IBAction)onAddPictureButtonPressed:(UIButton *)sender {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ActionTitle" message:@"ActionMessage" preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *takePictureAction = [UIAlertAction actionWithTitle:@"Take a Picture" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // Here you are going to write the code
        NSLog(@"Take Picture Action");
    }];

    UIAlertAction *photoLibraryAction = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // Here you are going to write the code
        NSLog(@"Photo Library Action");
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"Cancel Action");
    }];


    [alertController addAction:takePictureAction];
    [alertController addAction:photoLibraryAction];
    [alertController addAction:cancelAction];

    [self presentViewController:alertController animated:YES completion:nil];
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
