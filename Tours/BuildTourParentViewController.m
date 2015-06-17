//
//  BuildParentViewController.m
//  Tours
//
//  Created by Mark Porcella on 6/14/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BuildTourParentViewController.h"
#import "Tour.h"

@interface BuildTourParentViewController ()

@end

@implementation BuildTourParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(dismissCurrentViewController)];
    [self.navigationItem setLeftBarButtonItem:doneButton];

    BuildManager *buildManager = [BuildManager sharedBuildManager];
    self.tour = buildManager.tour;

}
-(void) dismissCurrentViewController {

    [self.tour saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}


@end
