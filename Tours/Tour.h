//
//  Tour.h
//  Tours
//
//  Created by Mark Porcella on 6/15/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@interface Tour : PFObject

@property NSString *title;
@property NSString *description;
//@property User *currentUser;

@end
