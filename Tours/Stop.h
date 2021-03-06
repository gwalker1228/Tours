//
//  Stop.h
//  Tours
//
//  Created by Mark Porcella on 6/15/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@class Tour;
@class User;

@interface Stop : PFObject <PFSubclassing>

@property NSString *title;
@property NSString *summary;
@property PFGeoPoint *location;
@property NSUInteger orderIndex;
@property Tour *tour;
@property User *creator;

+ (void) stopWithTour:(Tour *)tour withCompletion:(void(^)(Stop *stop, NSError *error))complete;
+ (void) stopWithTour:(Tour *)tour orderIndex:(int)index withCompletion:(void(^)(Stop *stop, NSError *error))complete;
- (void) deleteStopAndPhotosInBackground;

@end
