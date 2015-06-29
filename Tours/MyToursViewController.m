

#import "MyToursViewController.h"
#import "TourTableViewCell.h"
//#import "BuildTourParentViewController.h"
#import "IndexedPhotoCollectionView.h"
#import "IndexedPhotoCollectionViewCell.h"
#import "Tour.h"
#import "Photo.h"
#import "Stop.h"
#import "BuildTourDetailViewController.h"
#import "User.h"
#import "PhotoPopup.h"

@interface MyToursViewController () <UITableViewDataSource, UITableViewDelegate,  UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSArray *tours;
@property NSMutableDictionary *tourPhotos;
@property UIImageView *imageView;
@property UIView *blackView;

@end

@implementation MyToursViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithRed:252/255.0 green:255/255.0 blue:245/255.0 alpha:1.0];

}

- (void)viewWillAppear:(BOOL)animated {
    self.tours = [NSArray new];
//    NSLog(@"%@ %@", NSStringFromSelector(_cmd), [User currentUser]);
    if (![User currentUser]) {
        [self presentLogInViewController];
    } else {
        [self loadUserTours];
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


- (void)loadUserTours {

    PFQuery *query = [Tour query];
    [query whereKey:@"creator" equalTo:[User currentUser]];

    [query findObjectsInBackgroundWithBlock:^(NSArray *tours, NSError *error) {
        if (!error) {

            self.tours = tours;
            [self loadPhotos];
        } else {
            //error check
        }
    }];
}

-(void)loadPhotos {

    self.tourPhotos = [NSMutableDictionary new];

    for (Tour *tour in self.tours) {
        self.tourPhotos[tour.objectId] = [NSMutableArray new];
    }

    // Query parse for the first photo of every stop
    PFQuery *query = [Photo query];
    [query whereKey:@"creator" equalTo:[User currentUser]];

    [query findObjectsInBackgroundWithBlock:^(NSArray *photos, NSError *error){

        // For each photo related to tour, add to appropriate array in photoStops dictionary, based on the photo's associated stop
        NSLog(@"%@", photos);
        for (Photo *photo in photos) {

            Tour *photoTour = photo.tour; // get photo's tour
            [self.tourPhotos[photoTour.objectId] addObject:photo]; // add photo to that tour's photo array in tourPhotos dictionary
        }
        //        NSLog(@"%@", self.tourPhotos);
        [self.tableView reloadData];
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    BuildTourDetailViewController *destinationVC = (BuildTourDetailViewController *)[segue.destinationViewController topViewController];

    if ([segue.identifier isEqualToString:@"editTour"]) {

        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Tour *tour = self.tours[indexPath.row];
        destinationVC.tour = tour;

    }
    else if ([segue.identifier isEqualToString:@"addTour"]) {

        Tour *tour = [Tour object];
        destinationVC.tour = tour;
        destinationVC.tour.creator = [User currentUser];
        [tour save];
    }
}

#pragma mark - UITableView Delegate/DataSource methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TourTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TourTableViewCellIdentifier];

    if (cell == nil) {
        cell = [[TourTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TourTableViewCellIdentifier size:CGSizeMake(self.tableView.bounds.size.width, tableCellHeight)];
    }

    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];

    Tour *tour = [self.tours objectAtIndex:indexPath.row];

    cell.title = tour.title;
    cell.summary = tour.summary;
    cell.totalDistance = tour.totalDistance;
    cell.estimatedTime = tour.estimatedTime;

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.tours.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableCellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self performSegueWithIdentifier:@"editTour" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
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

    Tour* tour = self.tours[[(IndexedPhotoCollectionView *)collectionView indexPath].row];
    Photo *photo = self.tourPhotos[tour.objectId][indexPath.row];

    [PhotoPopup popupWithImage:cell.imageView.image photo:photo inView:self.view editable:NO delegate:nil];
}

@end







