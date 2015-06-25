//
//  BuildStopParentViewController.m
//  Tours
//
//  Created by Gretchen Walker on 6/16/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BuildStopParentViewController.h"
#import "Tour.h"


@interface BuildStopParentViewController ()

@property BuildManager *buildManager;
@end

@implementation BuildStopParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Save Stop" style:UIBarButtonItemStylePlain target:self action:@selector(dismissCurrentViewController)];
    [self.navigationItem setLeftBarButtonItem:doneButton];

    self.buildManager = [BuildManager sharedBuildManager];
    self.stop = self.buildManager.stop;
}

-(void) dismissCurrentViewController {

    self.navigationItem.leftBarButtonItem.enabled = NO;

    [self.stop saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            self.buildManager.stop = nil;
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}


@end