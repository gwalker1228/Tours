//
//  Stop.h
//  Tours
//
//  Created by Mark Porcella on 6/15/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <Parse/Parse.h>
@class Tour;

@interface Stop : PFObject

@property NSString *title;
@property NSString *description;
@property PFGeoPoint *location;
@property Tour *tour;

+ (void) stopWithTour:(Tour *)tour withCompletion:(void(^)(Stop *stop, NSError *error))complete;

@end
