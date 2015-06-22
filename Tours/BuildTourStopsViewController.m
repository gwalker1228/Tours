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

@property NSArray *stops;
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
        self.stops = stops;
        [self loadPhotos];
    }];
}

-(void)loadPhotos {

    self.stopPhotos = [NSMutableDictionary new];

    for (Stop *stop in self.stops) {
        self.stopPhotos[stop.title] = [NSMutableArray new];
    }

    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"tour" equalTo:self.tour];
    [query orderByAscending:@"order"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *photos, NSError *error){

        for (Photo *photo in photos) {

            NSString *photoStopTitle = photo.stop.title;
            [self.stopPhotos[photoStopTitle] addObject:photo];
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

    NSMutableArray *mutableStops = [self.stops mutableCopy];
    [mutableStops removeObjectAtIndex:sourceIndexPath.row];
    [mutableStops insertObject:stop atIndex:destinationIndexPath.row];

    self.stops = (NSArray *)mutableStops;
    [self updateStopOrderIndexesFromIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];

    [tableView reloadData];
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

    return [self.stopPhotos[stop.title] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    IndexedPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:indexedPhotoCollectionViewCellID forIndexPath:indexPath];
    NSNumber *tableViewCellnumber = [NSNumber numberWithLong:[(IndexedPhotoCollectionView *)collectionView indexPath].row];
    NSInteger tableViewCellInt = [tableViewCellnumber integerValue];

    Stop *stop = self.stops[tableViewCellInt];
    Photo *photo = self.stopPhotos[stop.title][indexPath.row];

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
