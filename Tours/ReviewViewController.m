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
#import "ReviewFlag.h"


@interface ReviewViewController () <RateViewDelegate, UITableViewDataSource, UITableViewDelegate, RatingTableViewCellDelegate, UIAlertViewDelegate>

@property RateView *rateView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UITextView *reviewTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *reviews;
@property NSMutableArray *flaggedReviews;
@property RatingTableViewCell *cell;
@property BOOL userLoggedIn;
@property float rating;
@property int totalReviews;
@property BOOL userPreviouslyRated;
@property Review *flaggedReview;


@property NSMutableArray *selectedIdexPaths; // test this when cell is built and apply automatic height (size to fit) if it's selected

@end

@implementation ReviewViewController

- (void)viewDidLoad {

    self.rating = 0;

    // assume she has previously rated until going through all the ratings and proving otherwise
    self.userPreviouslyRated = YES;

    self.flaggedReviews = [NSMutableArray new];
    [self fetchReviews];

    UIColor *lightGreen = [[UIColor alloc] initWithRed:(float)209/255 green:(float)219/255 blue:(float)189/255 alpha:1];
    self.reviewTextField.backgroundColor = lightGreen;
    self.selectedIdexPaths = [NSMutableArray new];
    self.reviews = [NSMutableArray new];

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

-(void)viewWillAppear:(BOOL)animated {

//    [[User currentUser] fetch];
    // added this because I've seen a couple of edge cases that had the button enabled when it shouldn't have been
    self.saveButton.enabled = NO;

    [self checkIfUserLoggedIn];
//        [self fetchReviews]; // for checking
    [self enableUserInteractionBasedRatingAndLoginStatus];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([self.selectedIdexPaths containsObject:indexPath]) {
        return UITableViewAutomaticDimension;
    } else {
        return 80;
    }
}

- (void)checkIfUserLoggedIn {

    if (![User currentUser]) {
        self.userLoggedIn = NO;
    } else {
        self.userLoggedIn = YES;
    }
}

- (IBAction)onSaveButtonPressed:(UIButton *)sender {

    [self saveReview];
}
- (IBAction)onLoginButtonPressed:(UIButton *)sender {

    [self presentLogInViewController];
}

- (void)saveReview {

    self.saveButton.enabled = NO;

    if (self.rating == 0) {

            // something wierd happened, just dissmiss the view controller.
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    [Review reviewWithUser:[User currentUser] tour:self.tour rating:self.rating reviewText:self.reviewTextField.text withCompletion:^(Review *review, NSError *error) {
        if (error == nil) {

            [self updateReviewRating];
        }
    }];

}

- (void) updateReviewRating {

    self.tour.averageRating = (self.tour.averageRating * self.totalReviews + self.rating) / (++self.totalReviews);
    [self.tour saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];

}

- (void) fetchReviews {

    PFQuery *query = [PFQuery queryWithClassName:@"Review"];
    [query whereKey:@"tour" equalTo:self.tour];
    [query includeKey:@"user"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *reviews, NSError *error){

        if (error == nil) {
            self.reviews = [self removeInvalidReviewsAndCheckForCurrentUserRating:reviews];
            [self fetchFlags];
        }
        else {
            NSLog(@"error on query");
        }
    }];
}

- (void) fetchFlags {

    if ([User currentUser]) {
        PFQuery *query = [ReviewFlag query];
        [query whereKey:@"tour" equalTo:self.tour];
        [query whereKey:@"user" equalTo:[User currentUser]];

        [query findObjectsInBackgroundWithBlock:^(NSArray *flags, NSError *error) {

            if (!error) {

                for (ReviewFlag *flag in flags) {
                    [flag.review fetchIfNeeded];
                    [self.flaggedReviews addObject:flag.review];
                }
            }
            [self.tableView reloadData];
        }];
    }
    else {
        [self.tableView reloadData];
    }
}

- (NSMutableArray *) removeInvalidReviewsAndCheckForCurrentUserRating:(NSArray *)reviews {

    NSMutableArray *validReviews = [NSMutableArray new];
    float totalReviewPts = 0;

        // default is they can rate it
    self.userPreviouslyRated = NO;
    for (Review *review in reviews) {

        totalReviewPts = totalReviewPts + review.rating;

        if (![review.reviewText isEqualToString:@"Please Add a review"] && ![review.reviewText isEqualToString:@""] ) {
            [validReviews addObject:review];
        }

            // set the userPreviouslyRated so the user can't rate the same tour mutiple times
        if (self.userLoggedIn) {
            if (review.user == [User currentUser]) {
                self.userPreviouslyRated = YES;
            }
        }
    }

        // Enable the ability to rate if the user hasn't already rated the tour and if she's logged in
        // need to do this here becuase it' executed after the reviews have been found
    [self enableUserInteractionBasedRatingAndLoginStatus];

        // needed to create a property for the total reviews for calculation when the user adds his rating
        // this is not the savme as the valid reviews because we count rating that have bad text here
    self.totalReviews = (float)[reviews count];
    return validReviews;
}

- (void) enableUserInteractionBasedRatingAndLoginStatus {

    if (self.userLoggedIn) {

        self.loginButton.hidden = YES;

        if (self.userPreviouslyRated == NO) {

            self.reviewTextField.userInteractionEnabled = YES;
            self.rateView.editable = YES;
            self.saveButton.enabled = YES;
            self.reviewTextField.text = @"Please Add a review";

        } else { // user has previously rated

            self.reviewTextField.userInteractionEnabled = NO;
            self.rateView.editable = NO;
            self.saveButton.enabled = NO;
            self.reviewTextField.text = @"Thank you for checking, but you've already rated this tour :-)";
        }
    } else { // User not logged in

        self.reviewTextField.userInteractionEnabled = NO;
        self.rateView.editable = NO;
        self.saveButton.enabled = NO;
        self.loginButton.enabled = YES;
        self.loginButton.hidden = NO;
        self.reviewTextField.text = @"Please Login to add a review";
    }

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

    [cell clearSubviews];

    Review *review = [self.reviews objectAtIndex:indexPath.row];

    cell.rateView.rating = review.rating; // set from Parse data

    if (![self.flaggedReviews containsObject:review]) {

        cell.reviewSummary.text = [NSString stringWithFormat:@"%@: %@", review.user.username, review.reviewText];

        cell.delegate = self;
        cell.review = review;

        [cell showFlagButton];
    }
    else {
        cell.reviewSummary.text = @"You have flagged this review as inappropriate.";
    }

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.reviews count];
}

- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating {

    self.rating = rating;
    if (self.userLoggedIn && self.userPreviouslyRated == NO) {
        self.saveButton.enabled = YES;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.reviewTextField resignFirstResponder];
}


#pragma mark - RatingTableViewCell Delegate methods

-(void)ratingTableViewCell:(RatingTableViewCell *)tableViewCell didPressFlagButtonForReview:(Review *)review {

    if ([User currentUser]) {

        self.flaggedReview = review;

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Flag this review as inappropriate?" message:@"You will not be able to undo this action" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Flag", nil];
        alertView.tag = 0;
        [alertView show];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You must be logged in to report content" message:nil delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Login/Signup", nil];
        alertView.tag = 1;
        [alertView show];
    }
}

#pragma mark - UIAlertView Delegate methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 1) {

        if (alertView.tag == 0) {

            ReviewFlag *reviewFlag = [ReviewFlag object];
            reviewFlag.review = self.flaggedReview;
            reviewFlag.user = [User currentUser];
            reviewFlag.tour = self.tour;

            [reviewFlag saveInBackground];
            [self.flaggedReviews addObject:self.flaggedReview];
            [self.tableView reloadData];
        }
        else if (alertView.tag == 1) {
            [self presentLogInViewController];
        }
    }
    self.flaggedReview = nil;
}

@end
