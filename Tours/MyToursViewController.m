

#import "MyToursViewController.h"
#import "TourTableViewCell.h"
#import "BuildManager.h"
#import "Tour.h"
#import "BuildTourParentViewController.h"
#import "User.h"

@interface MyToursViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSArray *tours;

@end

@implementation MyToursViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {
    self.tours = [NSArray new];
    [self fetchUserTours];

    if (![User currentUser]) {
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


- (void) fetchUserTours {
    PFQuery *query = [PFQuery queryWithClassName:@"Tour"];
    [query whereKey:@"creator" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {

            self.tours = [[[NSArray alloc] initWithArray:objects] mutableCopy];
            [self.tableView reloadData];
        } else {
            //error check
        }
    }];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TourTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    Tour *tour = [self.tours objectAtIndex:indexPath.row];
    cell.textLabel.text = tour.title;
    cell.detailTextLabel.text = tour.summary;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.tours count];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    BuildManager *buildManager = [BuildManager sharedBuildManager];

    if ([segue.identifier isEqualToString:@"EditTour"]) {

        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Tour *tour = [self.tours objectAtIndex:indexPath.row];
        buildManager.tour = tour;
        buildManager.tour.creator = [PFUser currentUser];

    } else {

        Tour *tour = [Tour object];
        buildManager.tour = tour;
        buildManager.tour.creator = [PFUser currentUser];
        [tour save];
    }
}









@end
