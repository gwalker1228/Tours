//
//  BuildStopGeneralViewController.m
//  Tours
//
//  Created by Mark Porcella on 6/14/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BuildStopGeneralViewController.h"


@interface BuildStopGeneralViewController ()

@property Stop *stop;
@property (weak, nonatomic) IBOutlet UITextField *buildStopGeneralTitle;
@property (weak, nonatomic) IBOutlet UITextView *buildStopGeneralTextField;


@end

@implementation BuildStopGeneralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    BuildManager *buildManager = [BuildManager sharedBuildManager];
    self.stop = buildManager.stop;
    self.buildStopGeneralTitle.text = self.stop.title;
    self.buildStopGeneralTextField.text = self.stop.summary;

}


- (void)viewWillDisappear:(BOOL)animated {

    self.stop.title = self.buildStopGeneralTitle.text;
    self.stop.summary = self.buildStopGeneralTextField.text;
}


@end
