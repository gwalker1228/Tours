//
//  BuildStopParentViewController.h
//  Tours
//
//  Created by Gretchen Walker on 6/16/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BuildManager.h"
#import "Stop.h"

@class Tour;

@interface BuildStopParentViewController : UIViewController

@property Stop *stop;

-(void) dismissCurrentViewController;

@end
