//
//  PageMasterViewController.m
//  Tours
//
//  Created by Adriana Jimenez Mangas on 6/19/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "StopPageMasterViewController.h"

@interface StopPageMasterViewController ()

@property (strong, nonatomic) UIPageViewController *pageViewController;

@property NSArray *pagesVC;
@property int currentIndex;
@property NSString *stepImageName;


@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIImageView *stepImageView;

@end

@implementation StopPageMasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createPageViewController];
}

- (void)createPageViewController {
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"StopPageVC"];

    UINavigationController *generalNC = [self.storyboard instantiateViewControllerWithIdentifier:@"StopGeneralNC"];
    UINavigationController *locationNC = [self.storyboard instantiateViewControllerWithIdentifier:@"StopLocationNC"];
    UINavigationController *photosNC = [self.storyboard instantiateViewControllerWithIdentifier:@"StopPhotosNC"];
    UINavigationController *previewNC = [self.storyboard instantiateViewControllerWithIdentifier:@"StopPreviewNC"];
    self.pagesVC = [NSArray arrayWithObjects:generalNC, locationNC, photosNC, previewNC, nil];

    self.currentIndex = 0;
    [self.pageViewController setViewControllers:@[[self viewControllerAtIndex:self.currentIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    self.stepImageName = [NSString stringWithFormat:@"step%d", self.currentIndex];
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



