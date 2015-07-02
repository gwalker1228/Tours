

#import "MyToursViewController.h"
#import "TourTableViewCell.h"
//#import "BuildTourParentViewController.h"
#import "BuildStopImagePickerViewController.h"
#import "BrowseTourDetailViewController.h"
#import "IndexedPhotoCollectionView.h"
#import "IndexedPhotoCollectionViewCell.h"
#import "Tour.h"
#import "Photo.h"
#import "Stop.h"
#import "BuildTourDetailViewController.h"
#import "User.h"
#import "PhotoPopup.h"

@interface MyToursViewController () <UITableViewDataSource, UITableViewDelegate,  UICollectionViewDataSource, UICollectionViewDelegate, TourTableViewCellDelegate, UISearchBarDelegate, PhotoPopupDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSArray *tours;
@property NSMutableDictionary *tourPhotos; // all photos displayed on page, key -> tourID : value = [array of photos for that tour]

@property NSMutableDictionary *validationErrors;
@property NSMutableArray *publishedTours;
@property NSMutableArray *notPublishedTours;
@property NSArray *filteredTours;

@property BOOL promptedLoginOnce;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property BOOL inProgressToursSelected;

@property PhotoPopup *photoPopup;

@end

@implementation MyToursViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithRed:252/255.0 green:255/255.0 blue:245/255.0 alpha:1.0];
    self.inProgressToursSelected = YES;
}

- (void)viewWillAppear:(BOOL)animated {


        // clear it everytime it views
    self.publishedTours = [NSMutableArray new];
    self.notPublishedTours = [NSMutableArray new];

    if (self.photoPopup) {
        [self.photoPopup reloadViews];
    }

    if (![User currentUser]) {
        if (!self.promptedLoginOnce) {
            self.promptedLoginOnce = YES;
            [self presentLogInViewController];
        }
        else {
            [self.parentViewController.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self loadUserTours];
    }

    self.searchBar.text = @"";
    self.tours = [NSArray new];
//    NSLog(@"%@ %@", NSStringFromSelector(_cmd), [User currentUser]);
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

- (void)loadUserTours {

    PFQuery *query = [Tour query];
    [query whereKey:@"creator" equalTo:[User currentUser]];

    [query findObjectsInBackgroundWithBlock:^(NSArray *tours, NSError *error) {
        if (!error) {
            for (Tour *tour in tours) {
                if (tour.published) {
                    [self.publishedTours addObject:tour];
                } else {
                    [self.notPublishedTours addObject:tour];
                }
            }
            if ([self.searchBar selectedScopeButtonIndex] == 0) {
                self.tours = self.notPublishedTours;
            } else {
                self.tours = self.publishedTours;
            }

            self.filteredTours = self.tours;

            [self loadPhotosForAllTours:tours];
        } else {
            //error check
        }
    }];
}

-(void)loadPhotosForAllTours:(NSArray *)tours {

    self.tourPhotos = [NSMutableDictionary new];

    for (Tour *tour in tours) {
        self.tourPhotos[tour.objectId] = [NSMutableArray new];
    }

    // Query parse for the first photo of every stop
    PFQuery *query = [Photo query];
    [query whereKey:@"creator" equalTo:[User currentUser]];
    [query whereKey:@"order" equalTo:@1];

    [query findObjectsInBackgroundWithBlock:^(NSArray *photos, NSError *error){

        // For each photo related to tour, add to appropriate array in photoStops dictionary, based on the photo's associated stop

        for (Photo *photo in photos) {

            Tour *photoTour = photo.tour; // get photo's tour
            [self.tourPhotos[photoTour.objectId] addObject:photo]; // add photo to that tour's photo array in tourPhotos dictionary
        }

        [self.tableView reloadData];
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {



    if ([segue.identifier isEqualToString:@"editTour"]) {
        BuildTourDetailViewController *destinationVC = (BuildTourDetailViewController *)[segue.destinationViewController topViewController];

        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Tour *tour = self.filteredTours[indexPath.row];
        destinationVC.tour = tour;

    }
    else if ([segue.identifier isEqualToString:@"addTour"]) {
        BuildTourDetailViewController *destinationVC = (BuildTourDetailViewController *)[segue.destinationViewController topViewController];

        Tour *tour = [Tour object];
        destinationVC.tour = tour;
        destinationVC.tour.creator = [User currentUser];
        [tour save];
    }

    else if ([segue.identifier isEqualToString:@"browseTour"]) {

        BrowseTourDetailViewController *destinationVC = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        destinationVC.tour = self.filteredTours[indexPath.row];
    }
}

#pragma mark - UITableView Delegate/DataSource methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TourTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TourTableViewCellIdentifier];

    if (cell == nil) {
        cell = [[TourTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TourTableViewCellIdentifier size:CGSizeMake(self.tableView.bounds.size.width, tableCellHeight)];
    }

    [cell clearVariableViews];
    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];

    Tour *tour = [self.filteredTours objectAtIndex:indexPath.row];

    cell.tour = tour;
    cell.delegate = self;
    cell.title = tour.title;
    cell.summary = tour.summary;
    cell.totalDistance = tour.totalDistance;
    cell.estimatedTime = tour.estimatedTime;

    if (!tour.published) {
         [cell showPublishButton];
    } else {
         cell.rating = tour.averageRating;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.filteredTours.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableCellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    Tour *tour = self.filteredTours[indexPath.row];

    [self performSegueWithIdentifier:(tour.published ? @"browseTour" : @"editTour") sender:[self.tableView cellForRowAtIndexPath:indexPath]];

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

    [PhotoPopup popupWithImage:cell.imageView.image photo:photo inView:self.view editable:(!tour.published) delegate:self];
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
    NSLog(@"view appeared");
}

-(void)photoPopup:(PhotoPopup *)photoPopup viewDidDisappear:(Photo *)photo {
    self.photoPopup = nil;
}

#pragma mark - UISearchBar Delegate methods

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {

    if (selectedScope == 0) {
        self.tours = self.notPublishedTours;
    } else {
        self.tours = self.publishedTours;
    }
    self.filteredTours = self.tours;
    self.searchBar.text = @"";
    [self.tableView reloadData];

}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

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

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
    [self.searchBar resignFirstResponder];
}


#pragma mark - validationMethods

- (void) validateTourForPublishing:(Tour *)tour {
    self.validationErrors = [NSMutableDictionary new];

    if ([tour.title isEqual:@"New Tour"]) {
        self.validationErrors[@"noTourTitle"] = @"YES";
    }

    if ([tour.summary isEqualToString:@"Write a brief description of the tour here."]) {
        self.validationErrors[@"noTourSummary"] = @"YES";
    }

        // We need to get the stops for each tour because we don't do this prior to validation
    PFQuery *query = [PFQuery queryWithClassName:@"Stop"];
    [query whereKey:@"tour" equalTo:tour];
    [query findObjectsInBackgroundWithBlock:^(NSArray *stops, NSError *error) {

        if (error == nil) {
            if (stops.count < 2) {
                self.validationErrors[@"objectMinimum"] = @"YES";
            }
        }
        [self ensureSelectedTour:tour hasAPhotoAssociatedWithEachStop:stops];
    }];
}

- (void) ensureSelectedTour:(Tour *)tour hasAPhotoAssociatedWithEachStop:(NSArray *)stops {

//    NSMutableArray *stopsWithNoPhotos = [NSMutableArray new];
    self.validationErrors[@"stopsWithNoPhotos"] = [NSMutableArray new];

    // Create a dictionary with key of the stopId and a mutableArray as the value to add photos to
    // stopPhotos -> key : stop.objectID, value : mutableArrayOfPHotos
    NSMutableDictionary *stopPhotos = [NSMutableDictionary new];
    for (Stop *stop in stops) {
        stopPhotos[stop.objectId] = [NSMutableArray new];
    }

    // We build tourPhotos to display the photos for each tour in each cell's respective collection view
    // Pulling the selected stop's photos out to compare to each stop
    // photosForStop = [all photos for this Tour
    NSMutableArray *allTourPhotos = self.tourPhotos[tour.objectId];

    // add the photo objects to the objectId key associated with each stop
    for (Photo *photo in allTourPhotos) {

        Stop *stop = photo.stop;
        [stopPhotos[stop.objectId] addObject:photo];
    }

    // count the number of photos just added and ensure it's greater than one
    for (Stop *stop in stops) {
        NSMutableArray *array = stopPhotos[stop.objectId];
//        NSLog(@"count of photos in each stop: %lu", array.count);
//        NSLog(@"stop title: %@", stop.title);
        if (array.count < 1) {
            [self.validationErrors[@"stopsWithNoPhotos"] addObject:stop];
        }
    }
        // Do the rest of the simple checks,
        //could have done it in the previous loop, but for understandability separating it..
        //need to send the tour through to to publish it if there are no validation errors
    [self ensureRemainingValidationsForStops:stops forTour:tour];

}

-(void) ensureRemainingValidationsForStops:(NSArray *)stops forTour:(Tour *)tour {

    self.validationErrors[@"stopsWithNoTitle"] = [NSMutableArray new];
    self.validationErrors[@"stopsWithNoLocation"] = [NSMutableArray new];
    self.validationErrors[@"stopsWithNoSummary"] = [NSMutableArray new];

    for (Stop *stop in stops) {
        if ([stop.title isEqualToString:@""]) {

            [self.validationErrors[@"stopsWithNoTitle"] addObject:stop];
        }

        if (stop.location == nil) {

            [self.validationErrors[@"stopsWithNoLocation"] addObject:stop];
        }

        if ([stop.summary isEqualToString:@""] || [stop.summary isEqualToString:@"Write a brief description of the tour here."]) {

            [self.validationErrors[@"stopsWithNoSummary"] addObject:stop];
        }
    }

    [self displayValidationErrorsToUserOrPublish:tour];
}

- (void)displayValidationErrorsToUserOrPublish:(Tour *)tour {

    NSString *validationMessage = @"";
    if ([self.validationErrors[@"objectMinimum"] isEqualToString:@"YES" ]) {
        validationMessage = [validationMessage stringByAppendingString:@"Please have at least two stops in your tour in order to publish\n\n"];
    }
    if ([self.validationErrors[@"noTourTitle"] isEqualToString:@"YES" ]) {
        validationMessage = [validationMessage stringByAppendingString:@"Please add a tour title (select \"New Tour\" in title bar of build tour section\n\n"];
    }
    if ([self.validationErrors[@"noTourSummary"] isEqualToString:@"YES" ]) {
        validationMessage = [validationMessage stringByAppendingString:@"Please add a tour summary by editing the text just above the map in the build tour seciton\n\n"];
    }

    NSArray *stopsWithNoPhoto = self.validationErrors[@"stopsWithNoPhotos"];
    if (stopsWithNoPhoto.count > 0) {
        validationMessage = [validationMessage stringByAppendingString:@"Please add a photo to: "];

        for (Stop *stop in stopsWithNoPhoto) {
            NSString *title = [NSString new];
            if ([stop.title isEqualToString:@""]) {
                title = @"Untitled Stop";
            } else {
                title = stop.title;
            }
            validationMessage = [validationMessage stringByAppendingString:[NSString stringWithFormat:@" %@,", title]];
        }
        validationMessage = [validationMessage stringByAppendingString:@"\n"];
    }

    NSArray *stopswithNoTitle = self.validationErrors[@"stopsWithNoTitle"];
    if (stopswithNoTitle.count > 0) {

        int numberOfStopsWithNoTitle = (int)[stopswithNoTitle count];
        validationMessage = [validationMessage stringByAppendingString:[NSString stringWithFormat:@"Please add a title to: %d of your stops. \n\n", numberOfStopsWithNoTitle]];
    }

    NSArray *stopswithNoLocation = self.validationErrors[@"stopsWithNoLocation"];
    if (stopswithNoLocation.count > 0) {
        validationMessage = [validationMessage stringByAppendingString:@"Please add a location to the following stops: "];
        for (Stop *stop in stopswithNoLocation) {
            NSString *title = [NSString new];
            if ([stop.title isEqualToString:@""]) {
                title = @"Untitled Stop";
            } else {
                title = stop.title;
            }
            validationMessage = [validationMessage stringByAppendingString:[NSString stringWithFormat:@" %@,", title]];
        }
        validationMessage = [validationMessage stringByAppendingString:@"\n\n"];
    }

    NSArray *stopswithNoSummary = self.validationErrors[@"stopsWithNoSummary"];
    if (stopswithNoSummary.count > 0) {
        validationMessage = [validationMessage stringByAppendingString:@"Please add a summary to the following stops: "];
        for (Stop *stop in stopswithNoSummary) {
            NSString *title = [NSString new];
            if ([stop.title isEqualToString:@""]) {
                title = @"Untitled Stop";
            } else {
                title = stop.title;
            }
            validationMessage = [validationMessage stringByAppendingString:[NSString stringWithFormat:@" %@,", title]];
        }
        validationMessage = [validationMessage stringByAppendingString:@"\n\n"];
    }
        // no problems with the tour
    if ([validationMessage isEqualToString:@""]) {

            // show an alert controller informing them that the tour can no longer be published and save it if they're happy with the tour
        UIAlertController *publishTourController = [UIAlertController alertControllerWithTitle:@"After publishing you will not be able to edit" message:@"Your tour passes all of the validation guidelines, and you can continue to publish it, but we wanted to give you a last chance to edit.  Thanks again for contributing!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *saveTour = [UIAlertAction actionWithTitle:@"Publish Tour" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self saveTheTour:tour];
        }];
        [publishTourController addAction:saveTour];
        [publishTourController addAction:cancel];
        [self presentViewController:publishTourController animated:YES completion:nil];

    } else {

        UIAlertController *validationProblemController = [UIAlertController alertControllerWithTitle:@"The Tour Needs Minor Work" message:validationMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *backToMyTours = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
        [validationProblemController addAction:backToMyTours];
        [self presentViewController:validationProblemController animated:YES completion:nil];
    }

}

- (void)saveTheTour:(Tour *)tour {
     // publish it and give a success message and move it to the publishedTours Array
    tour.published = YES;
    [tour saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error == nil) {
            // requery the data
            UIAlertController *successController = [UIAlertController alertControllerWithTitle:@"Published Successfully!" message:@"Other people can now view your tour.  Thank you for contributing :-)" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *backToMyTours = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
            [successController addAction:backToMyTours];
            [self presentViewController:successController animated:YES completion:nil];
            // move the array to the published array
            [self.notPublishedTours removeObject:tour];
            [self.publishedTours addObject:tour];
            self.tours = self.searchBar.selectedScopeButtonIndex ? self.notPublishedTours : self.publishedTours;
            self.filteredTours = self.tours;
            self.searchBar.text = @"";
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - TourTableViewCell Delegate Methods

-(void)tourTableViewCell:(TourTableViewCell *)tourTableViewCell publishTourButtonPressedForTour:(Tour *)tour {

    NSLog(@"tour title: %@", tour.title);
    [self validateTourForPublishing:tour];
}

@end







