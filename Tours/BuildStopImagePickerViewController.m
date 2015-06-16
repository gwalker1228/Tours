//
//  ImagePickerViewController.m
//  Tours
//
//  Created by Mark Porcella on 6/15/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BuildStopImagePickerViewController.h"
#import "Photo.h"
#import "Stop.h"
#import "BuildStopPhotoTableViewCell.h"

@interface BuildStopImagePickerViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *imageTitleTextField;

@property (weak, nonatomic) IBOutlet UITextField *imageSummaryTextField;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property BOOL firstViewDisplay;

@end

@implementation BuildStopImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.firstViewDisplay = YES;

    [self checkForCameraAvailableAndAlert];
    [self displayPhotoForEditingIfFromEditSegue];
    NSLog(@"initial view: %@", self.initialView);

}

-(void)viewWillAppear:(BOOL)animated {
    if (self.firstViewDisplay) {
        [self showSelectedImageAddOption];
        self.firstViewDisplay = NO;
    }
}
- (IBAction)onCancelButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onSaveButtonPressed:(UIButton *)sender {
    if (self.photo == nil) {
        NSString *imageTitle = self.imageTitleTextField.text;
        NSString *imageDescription = self.imageSummaryTextField.text;
        [Photo photoWithImage:self.imageView.image stop:self.stop title:imageTitle description:imageDescription withCompletion:^(Photo *photo, NSError *error) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    } else {
        self.photo.title = self.imageTitleTextField.text;
        self.photo.summary = self.imageSummaryTextField.text;
        [self.photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

- (void) displayPhotoForEditingIfFromEditSegue {
    if (self.photo) {
        self.imageTitleTextField.text = self.photo.title;
        self.imageSummaryTextField.text = self.photo.summary;
        PFFile *imageFile = self.photo.image;
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                self.imageView.image = image;
            }
        }];
    }
}

- (void) showSelectedImageAddOption {
    if ([self.initialView isEqualToString:@"camera"] && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self showCameraPickerController];
    } else if ([self.initialView isEqualToString:@"photoLibrary"]) {
        [self showPhotoLibraryPickerController];
    }
}

- (void) checkForCameraAvailableAndAlert {
    if ([self.initialView isEqualToString:@"camera"] && ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Device has no camera please use image picker." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [myAlertView show];
    }
}

- (void) showCameraPickerController {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void) showPhotoLibraryPickerController {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}






@end
