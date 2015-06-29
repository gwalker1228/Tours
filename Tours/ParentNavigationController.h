//
//  ParentNavigationController.h
//  Tours
//
//  Created by Adriana Jimenez Mangas on 6/25/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Tour;

@interface ParentNavigationController : UINavigationController

@property Tour *tour;  // The BrowseTourDetailVC wasn't able to pass the Tour through to the ReviewVC unless I added this property

@end
