//
//  CommentViewController.m
//  RatingViewController
//
//  Created by Mark Porcella on 6/24/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "ReviewViewController.h"
#import "Review.h"
#import "RatingTableViewCell.h"
#import <Parse/Parse.h>
#import "Tour.h"
#import "User.h"

@interface ReviewViewController () <RateViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property RateView *rateView;

@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UITextView *reviewTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *reviews;
//@property Review *review;
@property RatingTableViewCell *cell;

@property float rating;



@property NSMutableArray *selectedIdexPaths; // test this when cell is built and apply automatic height (size to fit) if it's selected

@end

@implementation ReviewViewController

- (void)viewDidLoad {

    self.tour = [Tour object];
    NSLog(@"tour title: %@", self.tour.title);
//    self.review = [Review object];
    self.rating = 0;
    self.saveButton.enabled = NO;
    [self fetchReviews];
//    UINavigationBar *bar = [self.navigationController navigationBar];
//    UIColor *lightColor = [[UIColor alloc] initWithRed:252.0/255.0 green:255.0/255.0 blue:245.0/255.0 alpha:1];
//    UIColor *darKBlueColor = [[UIColor alloc] initWithRed:25.0/255.0 green:52.0/255.0 blue:65.0/255.0 alpha:1];
//    [bar setTintColor:lightColor];
//    [bar setBackgroundColor:darKBlueColor];


    UIColor *lightGreen = [[UIColor alloc] initWithRed:(float)209/255 green:(float)219/255 blue:(float)189/255 alpha:1];
    self.reviewTextField.backgroundColor = lightGreen;
    self.selectedIdexPaths = [NSMutableArray new];
    self.reviews = [NSMutableArray new];

//    Review *commentOne = [Review new];
//    commentOne.user

//    [[Review alloc] initWithWhoMade:@"Bob" commentSummary:@"Ei tantas scaevola salutatus vim, per at decore assueverit, nam antiopam iudicabit an. Eum ut quas lucilius nominati. Qui ludus salutandi at, cu iusto sanctus has. Suas vituperata vis an, ceteros suscipit adolescens has te. Ut amet dicat quaerendum pri, brute sadipscing concludaturque ut eam" rating:4];
//
//
//
//    Review *commentTwo = [[Review alloc] initWithWhoMade:@"Jill" commentSummary:@"perata vis an,am" rating:5];
//
//    Review *commentThree = [[Review alloc] initWithWhoMade:@"Jill" commentSummary:@"Ei tantas scaevola salutatus vim, per at decore assueverit, nam antiopam iudicabit an. Eum ut quas lucilius nominati. Qui ludus salutandi at, cu iusto sanctus has. Suas vituperata vis an, ceteros suscipit adolescens has te. Ut amet dicat quaerendum pri, brute sadipscing concludaturque ut eam Ei tantas scaevola salutatus vim, per at decore assueverit, nam antiopam iudicabit an. \n Eum ut quas lucilius nominati. Qui ludus salutandi at, cu iusto sanctus has. Suas vituperata vis an, ceteros suscipit adolescens has te. Ut amet dicat quaerendum pri, brute sadipscing concludaturque ut eam. Ei tantas scaevola salutatus vim, per at decore assueverit, nam antiopam iudicabit an. Eum ut quas lucilius nominati. Qui ludus salutandi at, cu iusto sanctus has. Suas vituperata vis an, ceteros suscipit adolescens has te. Ut amet dicat quaerendum pri, brute sadipscing concludaturque ut eam." rating:2];
//Review    Review *commentFour = [[Comment alloc] initWithWhoMade:@"Jill" commentSummary:@"Ei tantas scaevola salutatus vim, per at decore assueverit, nam antiopam iudicabit an. Eum ut quas lucilius nominati. Qui ludus salutandi at, cu iusto sanctus has. Suas vituperata vis an, ceteros suscipit adolescens has te. Ut amet dicat quaerendum pri, brute sadipscing concludaturque ut eam" rating:4];
//
//    Review *commentFive = [[Review alloc] initWithWhoMade:@"Jill" commentSummary:@"perata vis an,am" rating:5];
//
//    [self.comments addObject:commentOne];
//    [self.comments addObject:commentTwo];
//    [self.comments addObject:commentThree];
//    [self.comments addObject:commentFour];
//    [self.comments addObject:commentFive];

    CGRect rateViewFrame = CGRectMake(20, 70, 160, 40);
    self.rateView = [[RateView alloc] initWithFrame:rateViewFrame];
    [self.view addSubview:self.rateView];
    self.rateView.rating = 0; // set from Parse data
    self.rateView.editable = YES; // or no depending on if we're in a comment or just viewing
    self.rateView.delegate = self;

}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([self.selectedIdexPaths containsObject:indexPath]) {
        return UITableViewAutomaticDimension;
    } else {
        return 70;
    }

}
- (IBAction)onSaveButtonPressed:(UIButton *)sender {

    [self saveReview];
}

- (void)saveReview {
    self.saveButton.enabled = NO;
    NSLog(@"tour: %@, user: %@, rating: %f, text: %@", self.tour, [User currentUser], self.rating, self.reviewTextField.text);

    [Review reviewWithUser:[User currentUser] tour:self.tour rating:self.rating reviewText:self.reviewTextField.text withCompletion:^(Review *review, NSError *error) {
        if (error == nil) {
            NSLog(@"saved");
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void) fetchReviews {

    PFQuery *query = [PFQuery queryWithClassName:@"Review"];
//    [query whereKey:@"tour" equalTo:self.tour];
    [query findObjectsInBackgroundWithBlock:^(NSArray *reviews, NSError *error){

        if (error == nil) {
            self.reviews = [reviews mutableCopy];
            [self.tableView reloadData];
        } else {
            NSLog(@"error on query");
        }

    }];

}

- (IBAction)onBackButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([self.selectedIdexPaths containsObject:indexPath]) {
        [self.selectedIdexPaths removeObject:indexPath];
    } else {
        [self.selectedIdexPaths addObject:indexPath];
    }
    [self.tableView reloadData];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    RatingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];

    Review *review = [self.reviews objectAtIndex:indexPath.row];
    NSLog(@"review Text: %@", review.reviewText);
    cell.reviewSummary.text = review.reviewText;

    NSLog(@"review text: %@", review.reviewText);

    CGRect rateViewFrame = CGRectMake(15, 5, 80, 20);
    RateView *rateView = [[RateView alloc] initWithFrame:rateViewFrame];
    rateView.rating = review.rating; // set from Parse data
    rateView.editable = NO; // or no depending on if we're in a comment or just viewing
    [cell addSubview:rateView];


    return cell;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.reviews count];

}

- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating {

    self.rating = rating;
    self.saveButton.enabled = YES;
    NSLog(@"Rating to be saveed: %@", [NSString stringWithFormat:@"Rating: %f", rating]);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.reviewTextField resignFirstResponder];
}







@end
