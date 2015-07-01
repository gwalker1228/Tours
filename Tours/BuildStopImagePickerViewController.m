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
#import "Tour.h"
#import "BuildStopPhotoTableViewCell.h"

@interface BuildStopImagePickerViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *imageTitleTextField;
@property (weak, nonatomic) IBOutlet UITextField *imageSummaryTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property BOOL photoChanged;

@property BOOL firstViewDisplay;

@end

@implementation BuildStopImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.photoChanged = NO;
    self.firstViewDisplay = YES;

    [self checkForCameraAvailableAndAlert];
    [self displayPhotoForEditingIfFromEditSegue];

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

    self.saveButton.enabled = NO;

        // If this is not from and edit segue, just save the new photo
    if (!self.photo) {

        NSString *imageTitle = self.imageTitleTextField.text;
        NSString *imageDescription = self.imageSummaryTextField.text;
        [Photo photoWithImage:self.imageView.image stop:self.stop tour:self.stop.tour title:imageTitle description:imageDescription orderNumber:self.orderNumber withCompletion:^(Photo *photo, NSError *error) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }  else {
            // if this is from an edit segue, only resave the image if they've changed it
        if (self.photoChanged) {
            self.photo.title = self.imageTitleTextField.text;
            self.photo.summary = self.imageSummaryTextField.text;

                
            [self.photo updatePhoto:self.photo photoWithImage:self.imageView.image title:self.imageTitleTextField.text description:self.imageSummaryTextField.text withCompletion:^(Photo *photo, NSError *error) {
                  [self dismissViewControllerAnimated:YES completion:nil];
            }];

        } else {

            // if they've only chancged the title or summary, only save that
            self.photo.title = self.imageTitleTextField.text;
            self.photo.summary = self.imageSummaryTextField.text;
            [self.photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }
    }
}

- (IBAction)onChangePhotoButtonPressed:(UIButton *)sender {

    self.photoChanged = YES;
    NSLog(@"photo has changed");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please Select Your Image Source" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *takePictureAction = [UIAlertAction actionWithTitle:@"Take a Picture" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

            // initialView is poorly named, but it is set when segueing from the add picture VC.  If not from that segue I set it here for the checkCamera...
        self.initialView = @"camera";
        [self checkForCameraAvailableAndAlert];
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            return;
        }
        [self showCameraPickerController];
    }];

    UIAlertAction *photoLibraryAction = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        [self showPhotoLibraryPickerController];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        self.photoChanged = NO;
    }];

    [alertController addAction:takePictureAction];
    [alertController addAction:photoLibraryAction];
    [alertController addAction:cancelAction];

    [self presentViewController:alertController animated:YES completion:nil];

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
                self.imageView.contentMode = UIViewContentModeScaleAspectFit;
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





