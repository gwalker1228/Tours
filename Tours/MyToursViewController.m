

#import "MyToursViewController.h"
#import "TourTableViewCell.h"
#import "BuildManager.h"
#import "Tour.h"

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
            Tour *tour = [self.tours firstObject];
            NSLog(@"first tour from query date: %@", tour.createdAt);
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

    NSLog(@"Tour count: %d", (int)[self.tours count]);
    return [self.tours count];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self performSegueWithIdentifier:@"editTour" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {


    BuildManager *buildManager = [BuildManager sharedBuildManager];
    if ([segue.identifier isEqualToString:@"editTour"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Tour *tour = [self.tours objectAtIndex:indexPath.row];
        buildManager.tour = tour;
    } else {
        Tour *tour = [Tour object];
        buildManager.tour = tour;
        [tour saveInBackground];
    }
}



@end
