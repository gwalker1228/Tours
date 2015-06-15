//
//  BuildParentViewController.m
//  Tours
//
//  Created by Mark Porcella on 6/14/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BuildParentViewController.h"

@interface BuildParentViewController ()

@end

@implementation BuildParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(dismissCurrentViewController)];
    [self.navigationItem setLeftBarButtonItem:doneButton];
}
-(void) dismissCurrentViewController {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
