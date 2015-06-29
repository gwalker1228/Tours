//
//  SearchAllToursViewController.m
//  Tours
//
//  Created by Gretchen Walker on 6/25/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BrowseAllToursViewController.h"
#import "BrowseTourDetailViewController.h"
#import "TourTableViewCell.h"
#import "TourDetailView.h"
#import "IndexedPhotoCollectionView.h"
#import "IndexedPhotoCollectionViewCell.h"
#import "Tour.h"
#import "Photo.h"
#import "Stop.h"
#import "User.h"

@interface BrowseAllToursViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property UIImageView *imageView;
@property UIView *blackView;

@property NSArray *tours;
@property NSMutableDictionary *tourPhotos;

@end

@implementation BrowseAllToursViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"All Tours";

    self.tableView.backgroundColor = [UIColor colorWithRed:252/255.0 green:255/255.0 blue:245/255.0 alpha:1.0];
}

-(void)viewWillAppear:(BOOL)animated {
    if (![User currentUser]) {
        [self presentLogInViewController];
    } else {
        [self loadTours];
    }
}

-(void)presentLogInViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navigationLoginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginNavigationVC"];

    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);

    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.parentViewController presentViewController:navigationLoginVC animated:YES completion:nil];
    });
}

- (IBAction)onLogoutButtonPressed:(UIBarButtonItem *)sender {
    NSLog(@"See you soon, %@", [User currentUser].username);
    [User logOut];
    [self presentLogInViewController];
}

-(void)loadTours {

    PFQuery *query = [PFQuery queryWithClassName:@"Tour"];
    [query orderByAscending:@"totalDistance"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *tours, NSError *error) {

        self.tours = tours;
//        for (int i = 0; i < (tours.count < 20 ? tours.count : 20); i++) {
//            [self.tours addObject:tours[i]];
//        }
        //NSLog(@"%@", self.tours);
        [self loadPhotos];
    }];
}

-(void)loadPhotos {

    self.tourPhotos = [NSMutableDictionary new];

    for (Tour *tour in self.tours) {
        self.tourPhotos[tour.objectId] = [NSMutableArray new];
    }

    // Query parse for the first photo of every stop
    PFQuery *query = [Photo query];
    [query whereKey:@"order" equalTo:@1];

    [query findObjectsInBackgroundWithBlock:^(NSArray *photos, NSError *error){

        // For each photo related to tour, add to appropriate array in photoStops dictionary, based on the photo's associated stop
        //NSLog(@"%@", photos);
        for (Photo *photo in photos) {

            Tour *photoTour = photo.tour; // get photo's tour
            [self.tourPhotos[photoTour.objectId] addObject:photo]; // add photo to that tour's photo array in tourPhotos dictionary
        }
//        NSLog(@"%@", self.tourPhotos);
        [self.tableView reloadData];
    }];
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"browseTour"]) {

        BrowseTourDetailViewController *destinationVC = segue.destinationViewController;
        destinationVC.tour = self.tours[[self.tableView indexPathForCell:sender].row];
    }
}

#pragma mark - UITableView Delegate/DataSource methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TourTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TourTableViewCellIdentifier];

    if (cell == nil) {
        cell = [[TourTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TourTableViewCellIdentifier size:CGSizeMake(self.tableView.bounds.size.width, tableCellHeight)];
    }

    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];

    Tour *tour = self.tours[indexPath.row];

    cell.title = tour.title;
    cell.summary = tour.summary;
    cell.totalDistance = tour.totalDistance;
    cell.estimatedTime = tour.estimatedTime;

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

//    NSLog(@"%lu", self.tours.count);
    return self.tours.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableCellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self performSegueWithIdentifier:@"browseTour" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
}

#pragma mark - UICollectionView Delegate/DataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    Tour *tour = self.tours[[(IndexedPhotoCollectionView *)collectionView indexPath].row];

    return [self.tourPhotos[tour.objectId] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    IndexedPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:indexedPhotoCollectionViewCellID forIndexPath:indexPath];

    Tour* tour = self.tours[[(IndexedPhotoCollectionView *)collectionView indexPath].row];
    Photo *photo = self.tourPhotos[tour.objectId][indexPath.row];

    cell.imageView.file = photo.image;
    [cell.imageView loadInBackground];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    IndexedPhotoCollectionViewCell *cell = (IndexedPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

    self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.imageView.image = cell.imageView.image;
    self.imageView.frame = CGRectMake(self.view.center.x, self.view.center.y, 0, 0);

    CGFloat imageSize = self.view.bounds.size.width;
    CGFloat originx = self.view.center.x - (imageSize / 2);
    CGFloat originy = self.view.center.y - (imageSize / 2);

    self.blackView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.blackView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    [self.view addSubview:self.blackView];

    [UIView animateWithDuration:.5 animations:^{

        [self.view addSubview:self.imageView];
        self.imageView.frame = CGRectMake(originx, originy, imageSize, imageSize);
        [self.view bringSubviewToFront:self.imageView];

    } completion:^(BOOL finished) {

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:self action:@selector(onViewTapped)];

        [self.imageView addGestureRecognizer:tap];
        [self.blackView addGestureRecognizer:tap];
    }];
}


- (void)onViewTapped {

    [UIView animateWithDuration:0.1 animations:^{

        self.imageView.frame = CGRectMake(self.view.center.x, self.view.center.y, 1, 1);
        self.blackView.frame = CGRectMake(self.view.center.x, self.view.center.y, 1, 1);

    } completion:^(BOOL finished) {

        [self.imageView removeFromSuperview];
        [self.blackView removeFromSuperview];
    }];
}


@end




