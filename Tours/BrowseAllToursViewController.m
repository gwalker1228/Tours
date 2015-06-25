//
//  SearchAllToursViewController.m
//  Tours
//
//  Created by Gretchen Walker on 6/25/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BrowseAllToursViewController.h"
#import "BrowseTourDetailViewController.h"
#import "Tour.h"

@interface BrowseAllToursViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSArray *tours;

@end

@implementation BrowseAllToursViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadTours];
}


-(void)loadTours {

   // self.tours = [NSMutableArray new];
    PFQuery *query = [PFQuery queryWithClassName:@"Tour"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *tours, NSError *error) {

        self.tours = tours;
//        for (int i = 0; i < (tours.count < 20 ? tours.count : 20); i++) {
//            [self.tours addObject:tours[i]];
//        }
        NSLog(@"%@", self.tours);
        [self.tableView reloadData];
    }];
}

- (IBAction)onLogoutButtonPressed:(UIBarButtonItem *)sender {
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"browseTour"]) {

        BrowseTourDetailViewController *destinationVC = segue.destinationViewController;
        destinationVC.tour = self.tours[[self.tableView indexPathForCell:sender].row];
    }
}

#pragma mark - UITableView Delegate/DataSource methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    Tour *tour = self.tours[indexPath.row];
    cell.textLabel.text = tour.title;
    NSLog(@"%@", tour.title);
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%lu", self.tours.count);
    return self.tours.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self performSegueWithIdentifier:@"browseTour" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
}

@end
