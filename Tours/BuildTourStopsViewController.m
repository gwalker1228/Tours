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


@interface CustomClass : NSObject

@property NSString *title;
@property NSString *detail;
@property NSArray *photos;

-(instancetype)initWithTitle:(NSString *)title detail:(NSString *)detail photos:(NSArray *)photos;

@end


@implementation CustomClass

-(instancetype)initWithTitle:(NSString *)title detail:(NSString *)detail photos:(NSArray *)photos {
    self = [super init];
    self.title = title;
    self.detail = detail;
    self.photos = photos;
    return self;
}


@end


@interface BuildTourStopsViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property Tour *tour;
@property NSArray *stops;

@property NSArray *objects;

@end

@implementation BuildTourStopsViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    BuildManager *buildManager = [BuildManager sharedBuildManager];
    self.tour = buildManager.tour;


    CustomClass *object1 = [[CustomClass alloc] initWithTitle:@"Title object 1" detail:@"Description number 1"
                                                       photos:@[@"2", @"4", @"1"]];
    CustomClass *object2 = [[CustomClass alloc] initWithTitle:@"Title object 2" detail:@"Description number 2"
                                                       photos:@[@"3", @"6", @"7", @"6"]];
    CustomClass *object3 = [[CustomClass alloc] initWithTitle:@"Title object 3" detail:@"Description number 2"
                                                       photos:@[@"6", @"2", @"3", @"4", @"2"]];
    CustomClass *object4 = [[CustomClass alloc] initWithTitle:@"Title object 4" detail:@"Description number 4"
                                                       photos:@[@"0", @"4", @"2", @"1", @"5", @"7"]];
    CustomClass *object5 = [[CustomClass alloc] initWithTitle:@"Title object 5" detail:@"Description number 5"
                                                       photos:@[@"1", @"2", @"3", @"4",@"5", @"6", @"7"]];
    self.objects = [NSArray arrayWithObjects:object1, object2, object3, object4, object5, nil];

    [self.tableView reloadData];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    BuildManager *buildManager = [BuildManager sharedBuildManager];

    Stop *stop = [Stop object];
    stop.tour = self.tour;
    buildManager.stop = stop;

    [stop saveInBackground];
}


#pragma mark - UITableViewDataSource & Delegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
//
//
//
//    return cell;

    BuildTourStopsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];

    CustomClass *object = self.objects[indexPath.row];

    cell.titleLabel.text = object.title;
    cell.descriptionLabel.text = object.detail;

    return cell;
}

//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    BuildTourStopsTableViewCell *tableCell = (BuildTourStopsTableViewCell *)cell;
//
//    [tableCell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
//
//    CustomClass *object = self.objects[indexPath.row];
//
//    tableCell.titleLabel.text = object.title;
//    tableCell.descriptionLabel.text = object.detail;
//}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableCellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.objects.count;
   // return self.stops.count;
}


#pragma mark - UICollectionViewDataSource, Delegate & DelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    CustomClass *object = self.objects[[(IndexedPhotoCollectionView *)collectionView indexPath].row];
    NSArray *collectionViewArray = object.photos;
    return collectionViewArray.count;
//    return 0;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

//    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
//
//    return cell;
    IndexedPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:indexedPhotoCollectionViewCellID forIndexPath:indexPath];

    CustomClass *object = self.objects[[(IndexedPhotoCollectionView *)collectionView indexPath].row];
    NSString *fileName = object.photos[indexPath.row];

   // cell.backgroundColor = [UIColor redColor];
    cell.imageView.image = [UIImage imageNamed:fileName];

    return cell;
}

@end
