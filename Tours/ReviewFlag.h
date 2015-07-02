//
//  ReviewFlag.h
//  Tours
//
//  Created by Gretchen Walker on 7/2/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@class User;
@class Review;
@class Tour;

@interface ReviewFlag : PFObject <PFSubclassing>

@property User *user;
@property Review *review;
@property Tour *tour;

@end
