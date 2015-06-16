//
//  BuildStopPhotosViewController.m
//  Tours
//
//  Created by Mark Porcella on 6/14/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BuildStopPhotosViewController.h"
#import <UIKit/UIKit.h>
#import "BuildStopImagePickerViewController.h"
#import "Stop.h"
#import "Photo.h"
#import "BuildStopPhotoTableViewCell.h"



@interface BuildStopPhotosViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *photos;


@end

@implementation BuildStopPhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];


}

- (void)viewWillAppear:(BOOL)animated {
    [self loadPhotos];
}

- (void) loadPhotos {
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];

    [query orderByDescending:@"createdAt"];
    [query setLimit:10]; // limiting the amount of pictures we're going to see

    //[query includeKey:@"image"]; // might be necessary

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {

            self.photos = [[[NSArray alloc] initWithArray:objects] mutableCopy];
            [self.tableView reloadData];
        }
    }];
}


- (IBAction)onAddPictureButtonPressed:(UIButton *)sender {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ActionTitle" message:@"ActionMessage" preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *takePictureAction = [UIAlertAction actionWithTitle:@"Take a Picture" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSegueWithIdentifier:@"camera" sender:self];
    }];

    UIAlertAction *photoLibraryAction = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSegueWithIdentifier:@"photoLibrary" sender:self];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];


    [alertController addAction:takePictureAction];
    [alertController addAction:photoLibraryAction];
    [alertController addAction:cancelAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    BuildStopPhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    Photo *photo = [self.photos objectAtIndex:indexPath.row];

    cell.buildStopPhotoTitle.text = photo.title;
    cell.buildStopPhotoSummary.text = photo.summary;

    PFFile *imageFile = photo.image;
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *cellImage = [UIImage imageWithData:data];
            cell.buildStopPhotoImageView.image = cellImage;
        }
    }];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.photos count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"editPhoto" sender:cell];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    BuildStopImagePickerViewController *vc = segue.destinationViewController;
    vc.initialView = segue.identifier;

    if ([segue.identifier isEqualToString:@"editPhoto"]) {
        BuildStopPhotoTableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        Photo *photoForEdit = [self.photos objectAtIndex:indexPath.row];
//        long i = indexPath.row;
//        NSLog(@"index %ld", i);
        vc.photo = photoForEdit;
    }

}







@end
