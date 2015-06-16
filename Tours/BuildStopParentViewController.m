//
//  BuildStopParentViewController.m
//  Tours
//
//  Created by Gretchen Walker on 6/16/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BuildStopParentViewController.h"
#import "Stop.h"

@interface BuildStopParentViewController ()

@end

@implementation BuildStopParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(dismissCurrentViewController)];
    [self.navigationItem setLeftBarButtonItem:doneButton];
}
-(void) dismissCurrentViewController {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


@end