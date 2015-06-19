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
#import <ParseUI/ParseUI.h>

@interface BuildStopPhotosViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *photos;
@property BOOL inEditingMode;

@end

@implementation BuildStopPhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.inEditingMode = NO;

}

- (void)viewWillAppear:(BOOL)animated {
    [self loadPhotos];
}

- (void) loadPhotos {

    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"stop" equalTo:self.stop];
    [query orderByAscending:@"order"];
    [query setLimit:10];
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

    cell.buildStopPhotoImageView.image = [UIImage imageNamed:@"redPin"]; // placeholder image

    Photo *photo = [self.photos objectAtIndex:indexPath.row];
//    cell.buildStopPhotoImageView.file = photo1.image;
//    [cell.buildStopPhotoImageView loadInBackground];
//
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


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {

    Photo *photo = [self.photos objectAtIndex:sourceIndexPath.row];
    [self.photos removeObject:photo];
    [self.photos insertObject:photo atIndex:destinationIndexPath.row];

    [self saveNewPhotoOrder];
    [self.tableView reloadData];
}


- (IBAction)onEditButtonPressed:(UIButton *)sender {
    if (!self.inEditingMode) {
        [sender setTitle:@"Done" forState:UIControlStateNormal];
        [self.tableView setEditing:YES animated:YES];
        self.inEditingMode = YES;
    } else {
        [sender setTitle:@"Edit" forState:UIControlStateNormal];
        [self.tableView setEditing:NO animated:YES];
        self.inEditingMode = NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {

        Photo *photo = [self.photos objectAtIndex:indexPath.row];
        [photo deleteInBackgroundWithBlock:^(BOOL completed, NSError *error) {
            if (!error) {
                [self.photos removeObjectAtIndex:indexPath.row];
                [self.tableView reloadData];
            } else {
                // Error handling
            }
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"editPhoto" sender:cell];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    BuildStopImagePickerViewController *vc = segue.destinationViewController;

    BuildManager *buildManager = [BuildManager sharedBuildManager];


    vc.initialView = segue.identifier;
    vc.stop = self.stop;
    vc.tour = buildManager.tour;

    vc.orderNumber = [self calculateInsertLocationForIncomingPhoto];

    if ([segue.identifier isEqualToString:@"editPhoto"]) {

        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Photo *photoForEdit = [self.photos objectAtIndex:indexPath.row];
        vc.photo = photoForEdit;
        vc.orderNumber = photoForEdit.order;
    }
}

- (NSNumber *) calculateInsertLocationForIncomingPhoto {
    
    int numberOfPhotos = (int)self.photos.count;
    numberOfPhotos++;
    return [NSNumber numberWithInt:numberOfPhotos];
}

- (void) saveNewPhotoOrder {

    int numberOfPhotos = (int)[self.photos count];
    for (int x = 0; x < numberOfPhotos; x++) {
        Photo *photo = [self.photos objectAtIndex:x];
        photo.order = [NSNumber numberWithInt:x+1];
        
        [photo saveInBackground];
    }
}









@end
