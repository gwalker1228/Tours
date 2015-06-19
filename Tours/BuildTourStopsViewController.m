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
@property NSArray *photos;
@property NSMutableArray *arrayOfArraysOfPhotos;


@end

@implementation BuildTourStopsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

-(void)viewWillAppear:(BOOL)animated {
    self.photos = [NSMutableArray new];
    self.arrayOfArraysOfPhotos = [NSMutableArray new];
    self.stops = [NSArray new];
    [self loadStops];

}

-(void)loadStops {

    PFQuery *query = [Stop query];
    [query whereKey:@"tour" equalTo:self.tour];
    [query findObjectsInBackgroundWithBlock:^(NSArray *stops, NSError *error) {
        self.stops = stops;
      [self findAllPhotosForThisTour];
    }];
}

- (void) findAllPhotosForThisTour {
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"tour" equalTo:self.tour];
    [query orderByAscending:@"order"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *photos, NSError *error){

        self.photos = photos;
        [self buildArrayOfPhotosForEachStopAndMakeAnArrayOfArrays];
    }];
}

- (void) buildArrayOfPhotosForEachStopAndMakeAnArrayOfArrays {
    for (Stop *stop in self.stops) {
        NSMutableArray *ArrayForSingleStop = [NSMutableArray new];

        for (Photo *photo in self.photos) {
            if (photo.stop == stop) {
                [ArrayForSingleStop addObject:photo];
            }
        }

        [self.arrayOfArraysOfPhotos addObject:ArrayForSingleStop];
    }
    [self.tableView reloadData];
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

#pragma mark - UICollectionViewDataSource, Delegate & DelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    Stop *stop = self.stops[[(IndexedPhotoCollectionView *)collectionView indexPath].row];

    int i = 0;
    for (Photo *photo in self.photos) {
        if (photo.stop == stop) {
            i++;
        }
    }
    return i;

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    IndexedPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:indexedPhotoCollectionViewCellID forIndexPath:indexPath];
    NSNumber *tableViewCellnumber = [NSNumber numberWithLong:[(IndexedPhotoCollectionView *)collectionView indexPath].row];
    NSInteger tableViewCellInt = [tableViewCellnumber integerValue];

    Photo *photo = [[self.arrayOfArraysOfPhotos objectAtIndex:tableViewCellInt] objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"redPin"]; // placeholder image
    cell.imageView.file = photo.image;
    [cell.imageView loadInBackground];
    return cell;

//    long collectionViewCell = indexPath.row;



//    if ([[self.arrayOfArraysOfPhotos objectAtIndex:tableViewCellInt] objectAtIndex:indexPath.row] != nil) {
//
//    }




//    PFFile *imageFile = photo.image;
//    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//        if (!error) {
//            UIImage *cellImage = [UIImage imageWithData:data];
//            cell.imageView.image = cellImage;
//        }
//    }];

//            NSInteger tableViewCellnumber = [NSNumber numberWithLong:[(IndexedPhotoCollectionView *)collectionView indexPath].row];

//
//    Stop *stop =  self.stops[[(IndexedPhotoCollectionView *)collectionView indexPath].row];
//    for (Photo *photo in self.photos) {
//        if (photo.stop == stop) {

//
//            PFImageView *imageView = [[PFImageView alloc] init];
//            imageView.image = [UIImage imageNamed:@"redPin"]; // placeholder image
//            imageView.file = photo.image;
           // imageView.file = (PFFile *)someObject[@"picture"]; // remote image
//            cell.imageView.image = imageView.image;
//            [imageView loadInBackground];
           // [imageView loadInBackground:^(PFImageView *image, NSError *error){


          //  }];

//            NSNumber *tableViewCellnumber = [NSNumber numberWithLong:[(IndexedPhotoCollectionView *)collectionView indexPath].row];
//            int intNumber = [number intValue];
//            NSLog(@"int value to add: %d", intNumber);
//            NSLog(@"index Path %lu", indexPath.row );
//            stopIndex = stopIndex + intNumber - 1;
//            stopIndex = stopIndex + indexPath.row - 1;
          //  NSLog(@"index path %lu", stopIndex);
//           // NSLog(@"stop index: %ld", (long)stopIndex);
//
//            NSInteger photoIndex = [self.photos indexOfObject:photo];
//            photoIndex = photoIndex + indexPath.row;
//            NSLog(@"photo index: %lu", photoIndex);
//            NSLog(@"indexPath.row: %lu", indexPath.row);
//            UIImage *image = [self.photoImages objectAtIndex:photoIndex];
//            cell.imageView.image = image;
//            NSLog(@"next loop");
//        }
//    }
//    NSLog(@"next collection View cell");

//
//    return cell;
   // cell.imageView.image = [UIImage imageNamed:@"redPin"];

 //   cell.imageView.image = [self.photoImages objectAtIndex:indexPath.row];


//    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
//    [query whereKey:@"stop" equalTo:stopForCollectionViewQuery];
//    [query whereKey:@"order" equalTo:[NSNumber numberWithLong:indexPath.row]];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
//        Photo *photo = [objects firstObject];
//        PFFile *imageFile = photo.image;
//        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//            if (!error) {
//                UIImage *cellImage = [UIImage imageWithData:data];
//                cell.imageView.image = cellImage;
//                [collectionView reloadData];
//            }
//        }];
//    }];



//    CustomClass *object = self.objects[[(IndexedPhotoCollectionView *)collectionView indexPath].row];
//    NSString *fileName = object.photos[indexPath.row];
////
////   // cell.backgroundColor = [UIColor redColor];
//    cell.imageView.image = [UIImage imageNamed:fileName];

//    return cell;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"addStop"]) {
        BuildManager *buildManager = [BuildManager sharedBuildManager];

        Stop *stop = [Stop object];
    
        stop.tour = self.tour;

        buildManager.stop = stop;

        [stop save];
    }
    //    else {
    //        stop = self.stops[[self.tableView indexPathForCell:sender].row];
    //        buildManager.stop = stop;
    //
    //        [self performSegueWithIdentifier:@"editStop" sender:self];
    //    }
}

@end
