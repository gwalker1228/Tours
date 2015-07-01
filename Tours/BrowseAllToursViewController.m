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
#import "PhotoPopup.h"
#import "Tour.h"
#import "Photo.h"
#import "Stop.h"
#import "User.h"

@interface BrowseAllToursViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property CLLocationManager *locationManager;

@property NSArray *tours;
@property NSArray *filteredTours;
@property NSMutableDictionary *tourPhotos;
@property NSMutableDictionary *distancesFromCurrentLocation;

@property BOOL distancesCalculated;
@property BOOL currentLocationFound;
@property BOOL toursLoaded;

@end

@implementation BrowseAllToursViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"All Tours";
    self.searchBar.delegate = self;

    self.tableView.backgroundColor = [UIColor colorWithRed:252/255.0 green:255/255.0 blue:245/255.0 alpha:1.0];

    self.distancesFromCurrentLocation = [NSMutableDictionary new];

    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    [self.locationManager requestWhenInUseAuthorization];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
    [self.navigationController.view addGestureRecognizer:tapRecognizer];
}

-(void)viewWillAppear:(BOOL)animated {

    [self loadTours];
    [[User currentUser] fetchIfNeeded];
    if (![User currentUser]) {
            
        [self.navigationItem.rightBarButtonItem setTitle:@"Login"];
    } else {

        [self.navigationItem.rightBarButtonItem setTitle:@"Logout"];
    }
}

- (IBAction)onLogoutButtonPressed:(UIBarButtonItem *)sender {

    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"Logout"]) {
        [self.navigationItem.rightBarButtonItem setTitle:@"Login"];
        [User logOut];
    } else {
        [self presentLogInViewController];
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

-(void)loadTours {

    PFQuery *query = [PFQuery queryWithClassName:@"Tour"];
    [query orderByAscending:@"totalDistance"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *tours, NSError *error) {

        self.tours = tours;
        self.filteredTours = tours;
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
        self.toursLoaded = YES;

        if (!self.distancesCalculated && self.currentLocationFound) {
            self.distancesCalculated = YES;

            [self calculateDistanceFromCurrentLocationForAllTours];
        }
        [self.tableView reloadData];
    }];
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"browseTour"]) {

        BrowseTourDetailViewController *destinationVC = segue.destinationViewController;
        destinationVC.tour = self.filteredTours[[self.tableView indexPathForCell:sender].row];
    }
}

-(void)calculateDistanceFromCurrentLocationForAllTours {

    for (Tour *tour in self.tours) {

        if (self.tourPhotos[tour.objectId]) {
            Photo *firstPhoto = [self.tourPhotos[tour.objectId] firstObject];
            Stop *firstStop = firstPhoto.stop;
            [firstStop fetchIfNeeded];
            NSLog(@"%@", firstStop);
            if (firstStop.location) {
                NSLog(@"%@", firstStop.location);
                double distance = [firstStop.location distanceInMilesTo:[PFGeoPoint geoPointWithLocation:[self.locationManager location]]];
                NSLog(@"%f", distance);

                self.distancesFromCurrentLocation[tour.objectId] = [NSString stringWithFormat:@"%.2f mi", distance];
            }
        }
    }
    [self.tableView reloadData];
}

#pragma mark - UITableView Delegate/DataSource methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TourTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TourTableViewCellIdentifier];

    if (cell == nil) {
        cell = [[TourTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TourTableViewCellIdentifier size:CGSizeMake(self.tableView.bounds.size.width, tableCellHeight)];
    }

    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];

    Tour *tour = self.filteredTours[indexPath.row];

    cell.title = tour.title;
    cell.summary = tour.summary;
    cell.totalDistance = tour.totalDistance;
    cell.estimatedTime = tour.estimatedTime;
    cell.distanceFromCurrentLocation = self.distancesFromCurrentLocation[tour.objectId];
    cell.rating = tour.averageRating;

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

//    NSLog(@"%lu", self.tours.count);
    return self.filteredTours.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableCellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self performSegueWithIdentifier:@"browseTour" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
}

#pragma mark - UICollectionView Delegate/DataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    Tour *tour = self.filteredTours[[(IndexedPhotoCollectionView *)collectionView indexPath].row];

    return [self.tourPhotos[tour.objectId] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    IndexedPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:indexedPhotoCollectionViewCellID forIndexPath:indexPath];

    Tour* tour = self.filteredTours[[(IndexedPhotoCollectionView *)collectionView indexPath].row];
    Photo *photo = self.tourPhotos[tour.objectId][indexPath.row];

    cell.imageView.file = photo.image;
    [cell.imageView loadInBackground];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    IndexedPhotoCollectionViewCell *cell = (IndexedPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

    Tour* tour = self.filteredTours[[(IndexedPhotoCollectionView *)collectionView indexPath].row];
    Photo *photo = self.tourPhotos[tour.objectId][indexPath.row];

    [PhotoPopup popupWithImage:cell.imageView.image photo:photo inView:self.view editable:NO delegate:nil];
}


#pragma mark - UISearchBar Delegate methods

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 0) {
        NSIndexSet *indexes = [self.tours indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [[[obj title] lowercaseString] containsString:[searchText lowercaseString]];
        }];

        self.filteredTours = [self.tours objectsAtIndexes:indexes];
    }
    else {
        self.filteredTours = self.tours;
    }
    [self.tableView reloadData];
}

-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {

    //reload tours based on index change
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
    [self.searchBar resignFirstResponder];
}

#pragma mark - CLLocationManager

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"gjlfgs");
    NSLog(@"%@", error);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    for (CLLocation *location in locations) {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {
            [self.locationManager stopUpdatingLocation];
            NSLog(@"location found");
            self.currentLocationFound = YES;
            if (!self.distancesCalculated && self.toursLoaded) {
                self.distancesCalculated = YES;
                [self calculateDistanceFromCurrentLocationForAllTours];
            }
            break;
        }
    }
}

@end




