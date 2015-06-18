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



@interface BuildTourStopsViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSArray *stops;

@end

@implementation BuildTourStopsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView reloadData];
    [self loadStops];
}

-(void)viewWillAppear:(BOOL)animated {
    [self loadStops];
}

-(void)loadStops {

    PFQuery *query = [Stop query];
    [query whereKey:@"tour" equalTo:self.tour];

    [query findObjectsInBackgroundWithBlock:^(NSArray *stops, NSError *error) {
        self.stops = stops;
        [self.tableView reloadData];
    }];
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

//    return self.objects.count;
    return self.stops.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   // [self performSegueWithIdentifier:@"editStop" sender:[tableView cellForRowAtIndexPath:indexPath]];
//
    BuildManager *buildManager = [BuildManager sharedBuildManager];
    Stop *stop = self.stops[indexPath.row];
    buildManager.stop = stop;

    [self performSegueWithIdentifier:@"editStop" sender:self];
}

#pragma mark - UICollectionViewDataSource, Delegate & DelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

  //  Stop *stop = self.stops[[(IndexedPhotoCollectionView *)collectionView indexPath].row];
//    CustomClass *object = self.objects[[(IndexedPhotoCollectionView *)collectionView indexPath].row];
//    NSArray *collectionViewArray = object.photos;
//    return collectionViewArray.count;
    return 0;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

//    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
//
//    return cell;
    IndexedPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:indexedPhotoCollectionViewCellID forIndexPath:indexPath];

//    CustomClass *object = self.objects[[(IndexedPhotoCollectionView *)collectionView indexPath].row];
//    NSString *fileName = object.photos[indexPath.row];
////
////   // cell.backgroundColor = [UIColor redColor];
//    cell.imageView.image = [UIImage imageNamed:fileName];

    return cell;
}

@end
