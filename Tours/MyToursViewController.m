

#import "MyToursViewController.h"
#import "TourTableViewCell.h"
#import "BuildManager.h"
#import "Tour.h"
#import "BuildTourParentViewController.h"

@interface MyToursViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSArray *tours;

@end

@implementation MyToursViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tours = [NSArray new];
    [self fetchUserTours];

}

- (void) fetchUserTours {
    PFQuery *query = [PFQuery queryWithClassName:@"Tour"];
//    [query whereKey:@"User" equalTo:self.user];
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
    cell.textLabel.text = [NSString stringWithFormat:@"date created:%@", tour.createdAt];
    cell.detailTextLabel.text = @"test";
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.tours count];
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    [self performSegueWithIdentifier:@"EditTour" sender:cell];
//}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

//    BuildTourParentViewController *parentVC = [BuildTourParentViewController new];
    BuildManager *buildManager = [BuildManager sharedBuildManager];
//    parentVC.buildManager = buildManager;

    if ([segue.identifier isEqualToString:@"EditTour"]) {

        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Tour *tour = [self.tours objectAtIndex:indexPath.row];
        buildManager.tour = tour;
        NSLog(@"segue tour passed creation at: %@", tour.createdAt);

    } else {

        Tour *tour = [Tour object];
        buildManager.tour = tour;
        [tour save];
    }
}



@end
