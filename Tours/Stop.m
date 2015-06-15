//
//  Stop.m
//  Tours
//
//  Created by Mark Porcella on 6/15/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "Stop.h"
#import "Tour.h"

@implementation Stop

@dynamic title;
@dynamic description;
@dynamic location;
@dynamic tour;

- (NSString * __nonnull)parseClassName {
    return @"Stop";
}

+ (instancetype) objectWithTour:(Tour *)tour {
    Stop *stop = [super object];
    stop.tour = tour;
    return stop;
}

+ (void) stopWithTour:(Tour *)tour withCompletion:(void(^)(Stop *stop, NSError *error))complete {
    Stop *stop = [Stop objectWithTour:tour];
    [stop saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        complete(stop, error);
    }];
}

@end
