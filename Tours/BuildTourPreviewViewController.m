//
//  BuildTourPreviewViewController.m
//  Tours
//
//  Created by Mark Porcella on 6/14/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BuildTourPreviewViewController.h"

@interface BuildTourPreviewViewController ()

@property Tour *tour;

@end

@implementation BuildTourPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    BuildManager *buildManager = [BuildManager sharedBuildManager];
    self.tour = buildManager.tour;
    
}


@end
