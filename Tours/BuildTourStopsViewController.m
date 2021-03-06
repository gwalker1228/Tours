//
//  BuildTourStopsViewController.m
//  Tours
//
//  Created by Mark Porcella on 6/14/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BuildTourStopsViewController.h"
#import "BuildTourStopsTableViewCell.h"
#import "BuildStopDetailViewController.h"
#import "IndexedPhotoCollectionView.h"
#import "IndexedPhotoCollectionViewCell.h"
#import "BuildStopImagePickerViewController.h"
#import "Stop.h"
#import "Photo.h"
#import "Tour.h"
#import "PhotoPopup.h"
#import <ParseUI/ParseUI.h>


@interface BuildTourStopsViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, PhotoPopupDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *addStopButton;
@property (weak, nonatomic) IBOutlet UIButton *editStopsButton;

@property NSMutableArray *stops;
@property NSMutableDictionary *stopPhotos;
@property BOOL isEditing;

@property PhotoPopup *photoPopup;

@end

@implementation BuildTourStopsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:252/255.0 green:255/255.0 blue:245/255.0 alpha:1.0];
    self.tableView.backgroundColor = [UIColor colorWithRed:252/255.0 green:255/255.0 blue:245/255.0 alpha:1.0];

//    for (UIButton *button in @[self.addStopButton, self.editStopsButton]) {
//        button.layer.borderColor = [UIColor blackColor].CGColor;
//        button.layer.borderWidth = 1.0f;
//    }
//    CGSize editButtonSize = CGSizeMake(100, 30);
//    CGPoint editButtonOrigin = CGPointMake(self.view.layer.bounds.size.width - editButtonSize.width - 8, 0);
//    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(editButtonOrigin.x, editButtonOrigin.y, editButtonSize.width, editButtonSize.height)];
//    [editButton setBackgroundColor:[UIColor redColor]];
//    [editButton setTitle:@"Edit Stops" forState:UIControlStateNormal];
//
//    [editButton addTarget:self action:@selector(onEditButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//
//    [self.view addSubview:editButton];

}

-(void)viewWillAppear:(BOOL)animated {

    if (self.photoPopup) {
        [self.photoPopup reloadViews];
    }

    [self loadStops];
}

-(void)loadStops {

    PFQuery *query = [Stop query];
    [query whereKey:@"tour" equalTo:self.tour];
    [query orderByAscending:@"orderIndex"];
//    UIColor *lightGreenColor = [[UIColor alloc] initWithRed:209.0/255.0 green:219.0/255.0 blue:189.0/255.0 alpha:1];
//    self.editStopsButton.backgroundColor = lightGreenColor;
//    self.addStopButton.backgroundColor = lightGreenColor;
    [query findObjectsInBackgroundWithBlock:^(NSArray *stops, NSError *error) {
//        self.stops = [stops mutableCopy];

            // don't allow stops without location to show up
        NSMutableArray *mutableArray = [NSMutableArray new];
        for (Stop *stop in stops) {
            if (stop.location != nil) {
                [mutableArray addObject:stop];
            }
        }
        self.stops = mutableArray;

        [self loadPhotos];
    }];
}

-(void)loadPhotos {

     /*
        Photos are stored in NSMutableDictionary *stopPhotos. A key is created for each stop using the stop's title. The value of that key is a mutable array 
        to which photos for that particular stop are stored. When this method completes, the dictionary will look something like:
      
      NSMutableDictionary *stopPhotos =
      {
        firstStop_objectID : [Photo1, Photo2, Photo3, ...],
        secondStop_objectID : [Photo1, Photo2, Photo3, ...],

        .
        .
        .

        lastStop_objectID : [Photo1, Photo2, ...]
      }
    */

    // Initialize dictionary with keys for stop titles and an empty mutable array for each key
    self.stopPhotos = [NSMutableDictionary new];

    for (Stop *stop in self.stops) {
        self.stopPhotos[stop.objectId] = [NSMutableArray new];
    }

    // Query parse for all photos related to tour
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"tour" equalTo:self.tour];
    [query orderByAscending:@"order"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *photos, NSError *error){

        // For each photo related to tour, add to appropriate array in photoStops dictionary, based on the photo's associated stop
        for (Photo *photo in photos) {

            Stop *photoStop = photo.stop; // get photo's stop
            [self.stopPhotos[photoStop.objectId] addObject:photo]; // add photo to that stop's photo array in photoStops dictionary
        }
        [self.tableView reloadData];
    }];
}

- (IBAction)onEditButtonPressed:(UIButton *)sender {

    if (self.isEditing) {

        self.isEditing = NO;
        [sender setTitle:@"Reorder/Delete Stops" forState:UIControlStateNormal];
        UIColor *lightGreenColor = [[UIColor alloc] initWithRed:209.0/255.0 green:219.0/255.0 blue:189.0/255.0 alpha:1];
        sender.backgroundColor = lightGreenColor;
        [sender setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.tableView setEditing:(self.isEditing) animated:YES];

    } else {

        self.isEditing = YES;
        [self.tableView setEditing:(self.isEditing) animated:NO];
        UIColor *darKBlueColor = [[UIColor alloc] initWithRed:25.0/255.0 green:52.0/255.0 blue:65.0/255.0 alpha:1];
        sender.backgroundColor = darKBlueColor;
        UIColor *lightColor = [[UIColor alloc] initWithRed:252.0/255.0 green:255.0/255.0 blue:245.0/255.0 alpha:1];
        [sender setTitleColor:lightColor forState:UIControlStateNormal];
        [sender setTitle:@"Save Order" forState:UIControlStateNormal];
        
    }
}

- (IBAction)onBackButtonPressed:(UIBarButtonItem *)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource & Delegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    BuildTourStopsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BuildTourStopsTableViewCellIdentifier];

    if (cell == nil) {
        cell = [[BuildTourStopsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BuildTourStopsTableViewCellIdentifier size:CGSizeMake(self.tableView.bounds.size.width, tableCellHeight)];
    }

    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];

    Stop *stop = self.stops[indexPath.row];
    cell.title = [NSString stringWithFormat:@"%d. %@", (int)indexPath.row + 1, stop.title];
//    UIFont *currentFont = cell.title;
//    UIFont *newFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",currentFont.fontName] size:currentFont.pointSize];
//    cell.title.
    cell.summary =  stop.summary;
    return cell;
}


-(void)boldFontForLabel:(UILabel *)label{
    UIFont *currentFont = label.font;
    UIFont *newFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",currentFont.fontName] size:currentFont.pointSize];
    label.font = newFont;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableCellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.stops.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

//    BuildManager *buildManager = [BuildManager sharedBuildManager];
//    Stop *stop = self.stops[indexPath.row];
//    buildManager.stop = stop;

    [self performSegueWithIdentifier:@"editStop" sender:self];
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {

    Stop *stop = self.stops[sourceIndexPath.row];

    [self.stops removeObjectAtIndex:sourceIndexPath.row];
    [self.stops insertObject:stop atIndex:destinationIndexPath.row];

    if (sourceIndexPath.row > destinationIndexPath.row) {
        NSIndexPath *temp = sourceIndexPath;
        sourceIndexPath = destinationIndexPath;
        destinationIndexPath = temp;
    }

    [self updateStopOrderIndexesFromIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];

    [tableView reloadData];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {

        Stop *stop = self.stops[indexPath.row];
        [self.stops removeObjectAtIndex:indexPath.row];

        [stop deleteStopAndPhotosInBackground];

        [self updateStopOrderIndexesFromIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:self.stops.count-1 inSection:0]];

        [tableView reloadData];
    }
}

-(void) updateStopOrderIndexesFromIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {

    for (NSUInteger i = sourceIndexPath.row; i <= destinationIndexPath.row; i++) {

        Stop *stop = self.stops[i];

        stop.orderIndex = i;
        [stop saveInBackground];
    }
}

#pragma mark - UICollectionViewDataSource, Delegate & DelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    Stop *stop = self.stops[[(IndexedPhotoCollectionView *)collectionView indexPath].row];

    return [self.stopPhotos[stop.objectId] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    IndexedPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:indexedPhotoCollectionViewCellID forIndexPath:indexPath];

    Stop *stop = self.stops[[(IndexedPhotoCollectionView *)collectionView indexPath].row];
    Photo *photo = self.stopPhotos[stop.objectId][indexPath.row];

    cell.imageView.file = photo.image;
    [cell.imageView loadInBackground];

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    IndexedPhotoCollectionViewCell *cell = (IndexedPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];


    Stop* stop = self.stops[[(IndexedPhotoCollectionView *)collectionView indexPath].row];
    Photo *photo = self.stopPhotos[stop.objectId][indexPath.row];

    [PhotoPopup popupWithImage:cell.imageView.image photo:photo inView:self.view.superview editable:YES delegate:self];
}

#pragma mark - PhotoPopup Delegate methods

-(void)photoPopup:(PhotoPopup *)photoPopup editPhotoButtonPressed:(Photo *)photo {

    Stop* stop = photo.stop;
    [stop fetchIfNeeded];
    Tour *tour = photo.tour;
    [tour fetchIfNeeded];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BuildStopImagePickerViewController *buildStopImagePickerVC = [storyboard instantiateViewControllerWithIdentifier:@"BuildStopImagePickerVC"];

    buildStopImagePickerVC.photo = photo;
    buildStopImagePickerVC.stop = stop;
    buildStopImagePickerVC.tour = tour;

    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);

    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.parentViewController presentViewController:buildStopImagePickerVC animated:YES completion:nil];
    });
}

-(void)photoPopup:(PhotoPopup *)photoPopup viewDidAppear:(Photo *)photo {
    self.photoPopup = photoPopup;
}

-(void)photoPopup:(PhotoPopup *)photoPopup viewDidDisappear:(Photo *)photo {
    self.photoPopup = nil;
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    BuildStopDetailViewController *destinationVC = (BuildStopDetailViewController *)[segue.destinationViewController topViewController];

    if ([segue.identifier isEqualToString:@"addStop"]) {
        //BuildManager *buildManager = [BuildManager sharedBuildManager];

        Stop *stop = [Stop object];
    
        stop.tour = self.tour;
        stop.orderIndex = self.stops.count;
        destinationVC.stop = stop;

        [stop save];
    }
    else if ([segue.identifier isEqualToString:@"editStop"]) {

        destinationVC.stop = self.stops[[self.tableView indexPathForSelectedRow].row];
    }
}

@end




