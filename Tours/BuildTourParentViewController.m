//
//  BuildParentViewController.m
//  Tours
//
//  Created by Mark Porcella on 6/14/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BuildTourParentViewController.h"


@interface BuildTourParentViewController ()

@property BuildManager *buildManager;

@end

@implementation BuildTourParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(dismissCurrentViewController)];
    [self.navigationItem setLeftBarButtonItem:doneButton];


    self.buildManager = [BuildManager sharedBuildManager];
    self.tour = self.buildManager.tour;
}
-(void) dismissCurrentViewController {

    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    [self.tour saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        self.buildManager.tour = nil;
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}


@end
