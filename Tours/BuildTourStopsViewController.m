//
//  BuildTourStopsViewController.m
//  Tours
//
//  Created by Mark Porcella on 6/14/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BuildTourStopsViewController.h"
#import "BuildTourStopsTableViewCell.h"
#import "IndexedPhotoCollectionView.h"
#import "IndexedPhotoCollectionViewCell.h"
#import "Stop.h"
#import "Photo.h"
#import "Tour.h"
#import <ParseUI/ParseUI.h>


@interface BuildTourStopsViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *stops;
@property NSMutableDictionary *stopPhotos;
@property BOOL isEditing;


@end

@implementation BuildTourStopsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CGSize editButtonSize = CGSizeMake(100, 30);
    CGPoint editButtonOrigin = CGPointMake(self.view.layer.bounds.size.width - editButtonSize.width - 8, 0);
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(editButtonOrigin.x, editButtonOrigin.y, editButtonSize.width, editButtonSize.height)];
    [editButton setBackgroundColor:[UIColor redColor]];
    [editButton setTitle:@"Edit Stops" forState:UIControlStateNormal];

    [editButton addTarget:self action:@selector(onEditButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:editButton];

}

-(void)viewWillAppear:(BOOL)animated {
    [self loadStops];
}

-(void)loadStops {

    PFQuery *query = [Stop query];
    [query whereKey:@"tour" equalTo:self.tour];
    [query orderByAscending:@"orderIndex"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *stops, NSError *error) {
        self.stops = [stops mutableCopy];
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

- (void)onEditButtonPressed:(UIButton *)sender {

    self.isEditing = !self.isEditing;
    [self.tableView setEditing:(self.isEditing) animated:YES];
}


#pragma mark - UITableViewDataSource & Delegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    BuildTourStopsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BuildTourStopsTableViewCellIdentifier];

    if (cell == nil) {
        cell = [[BuildTourStopsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BuildTourStopsTableViewCellIdentifier size:CGSizeMake(self.tableView.bounds.size.width, tableCellHeight)];

    }

    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];

    Stop *stop = self.stops[indexPath.row];

    cell.title = stop.title;
    cell.summary = stop.summary;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableCellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.stops.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    BuildManager *buildManager = [BuildManager sharedBuildManager];
    Stop *stop = self.stops[indexPath.row];
    buildManager.stop = stop;

    [self performSegueWithIdentifier:@"editStop" sender:self];
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {

    Stop *stop = self.stops[sourceIndexPath.row];

    [self.stops removeObjectAtIndex:sourceIndexPath.row];
    [self.stops insertObject:stop atIndex:destinationIndexPath.row];

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
    NSNumber *tableViewCellnumber = [NSNumber numberWithLong:[(IndexedPhotoCollectionView *)collectionView indexPath].row];
    NSInteger tableViewCellInt = [tableViewCellnumber integerValue];

    Stop *stop = self.stops[tableViewCellInt];
    Photo *photo = self.stopPhotos[stop.objectId][indexPath.row];

    cell.imageView.image = [UIImage imageNamed:@"redPin"]; // placeholder image
    cell.imageView.file = photo.image;
    [cell.imageView loadInBackground];
    return cell;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"addStop"]) {
        BuildManager *buildManager = [BuildManager sharedBuildManager];

        Stop *stop = [Stop object];
    
        stop.tour = self.tour;
        stop.orderIndex = self.stops.count;
        buildManager.stop = stop;

        [stop save];
    }
}

@end
