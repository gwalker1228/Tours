//
//  Review.h
//  Tours
//
//  Created by Mark Porcella on 6/28/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@class Tour;
@class User;

@interface Review : PFObject <PFSubclassing>

@property User *user;
@property Tour *tour;
@property float rating;
@property NSString *reviewText;

+ (void) reviewWithUser:(User *)user tour:(Tour *)tour rating:(float)rating reviewText:(NSString *)reviewText withCompletion:(void (^)(Review *review, NSError *error))complete;

@end

