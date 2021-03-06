//
//  ParentNavigationController.m
//  Tours
//
//  Created by Adriana Jimenez Mangas on 6/25/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "ParentNavigationController.h"


@interface ParentNavigationController ()

@end

@implementation ParentNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIColor *color1 = [UIColor colorWithRed:252/255.0f green:255/255.0f blue:245/255.0f alpha:1.0];
    UIColor *color5 = [UIColor colorWithRed:25/255.0f green:52/255.0f blue:65/255.0f alpha:1.0];

    self.navigationBar.barTintColor = color5;
    self.navigationBar.tintColor = color1;

    self.navigationBar.barStyle = UIBarStyleBlackOpaque;

    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes: @{NSFontAttributeName:[UIFont fontWithName:@"AvenirNextCondensed-Medium" size:16]} forState:UIControlStateNormal];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:23]}];
}


@end
