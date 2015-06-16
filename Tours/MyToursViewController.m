//
//  MySavedToursViewController.m
//  Tours
//
//  Created by Mark Porcella on 6/14/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "MyToursViewController.h"
#import "BuildManager.h"
#import "Tour.h"

@interface MyToursViewController ()

@end

@implementation MyToursViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    BuildManager *buildManager = [BuildManager sharedBuildManager];
    Tour *tour = [Tour object];

    buildManager.tour = tour;
    [tour saveInBackground];
}

@end
