//
//  BuildStopPreviewViewController.m
//  Tours
//
//  Created by Mark Porcella on 6/14/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BuildStopPreviewViewController.h"

@interface BuildStopPreviewViewController ()

@property Stop *stop;

@end

@implementation BuildStopPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    BuildManager *buildManager = [BuildManager sharedBuildManager];
    self.stop = buildManager.stop;
}




@end
