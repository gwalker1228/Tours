//
//  Tour.h
//  Tours
//
//  Created by Mark Porcella on 6/15/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
@class User;

@interface Tour : PFObject <PFSubclassing>

@property NSString *title;
@property NSString *summary;
@property User *creator;
@property float totalDistance;
@property float estimatedTime;
@property float averageRating;

@end
