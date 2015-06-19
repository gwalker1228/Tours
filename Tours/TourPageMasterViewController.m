//
//  TourPageMasterViewController.m
//  Tours
//
//  Created by Adriana Jimenez Mangas on 6/19/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "TourPageMasterViewController.h"

@interface TourPageMasterViewController ()

@property (strong, nonatomic) UIPageViewController *pageViewController;

@property NSArray *pagesVC;
@property int currentIndex;
@property NSString *stepImageName;

@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (weak, nonatomic) IBOutlet UIImageView *stepImageView;

@end

@implementation TourPageMasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createPageViewController];
}

- (void)createPageViewController {
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TourPageVC"];

    UINavigationController *generalNC = [self.storyboard instantiateViewControllerWithIdentifier:@"TourGeneralNC"];
    UINavigationController *stopsNC = [self.storyboard instantiateViewControllerWithIdentifier:@"TourStopsNC"];
    UINavigationController *previewNC = [self.storyboard instantiateViewControllerWithIdentifier:@"TourPreviewNC"];
    UINavigationController *itemNC = [self.storyboard instantiateViewControllerWithIdentifier:@"TourItemNC"];
    self.pagesVC = [NSArray arrayWithObjects:generalNC, stopsNC, previewNC, itemNC, nil];

    self.currentIndex = 0;
    self.stepImageName = [NSString stringWithFormat:@"step%d", self.currentIndex];
    [self.pageViewController setViewControllers:@[[self viewControllerAtIndex:self.currentIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width - 0, self.view.frame.size.height - 35);

    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];

    self.previousButton.alpha = 0;
    [self.view bringSubviewToFront:self.previousButton];
    [self.view bringSubviewToFront:self.nextButton];

    self.stepImageView.image= [UIImage imageNamed:self.stepImageName];
}


-(UINavigationController *)viewControllerAtIndex:(int)index {
    return self.pagesVC[index];
}



- (IBAction)onPreviousButtonPressed:(UIButton *)sender {

    if (self.nextButton.alpha == 0) { self.nextButton.alpha = 1; }

    if (self.currentIndex > 0) {
        self.currentIndex--;
        [self.pageViewController setViewControllers:@[[self viewControllerAtIndex:self.currentIndex]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    }

    if (self.currentIndex == 0) {
        self.previousButton.alpha = 0;
    }

    self.stepImageName = [NSString stringWithFormat:@"step%d", self.currentIndex];
    self.stepImageView.image = [UIImage imageNamed:self.stepImageName];
}


- (IBAction)onNextButtonPressed:(UIButton *)sender {

    if (self.previousButton.alpha == 0) { self.previousButton.alpha = 1; }

    if (self.currentIndex < self.pagesVC.count - 1) {
        self.currentIndex++;
        [self.pageViewController setViewControllers:@[[self viewControllerAtIndex:self.currentIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }

    if (self.currentIndex == self.pagesVC.count -1) {
        self.nextButton.alpha = 0;
    }
    
    self.stepImageName = [NSString stringWithFormat:@"step%d", self.currentIndex];
    self.stepImageView.image = [UIImage imageNamed:self.stepImageName];
}


@end




