//
//  Stop.m
//  Tours
//
//  Created by Mark Porcella on 6/15/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "Stop.h"
#import "Tour.h"
#import "Photo.h"
#import "User.h"

@implementation Stop

@dynamic title;
@dynamic summary;
@dynamic location;
@dynamic orderIndex;
@dynamic tour;
@dynamic creator;

+ (NSString * __nonnull)parseClassName {
    return @"Stop";
}

+ (instancetype) objectWithTour:(Tour *)tour {
    Stop *stop = [super object];
    stop.tour = tour;
    stop.creator = [User currentUser];
    return stop;
}

+ (instancetype) objectWithTour:(Tour *)tour orderIndex:(int)index {
    Stop *stop = [super object];
    stop.orderIndex = index;
    stop.tour = tour;
    stop.creator = [User currentUser];
    return stop;
}

+ (void) stopWithTour:(Tour *)tour withCompletion:(void(^)(Stop *stop, NSError *error))complete {
    Stop *stop = [Stop objectWithTour:tour];
    [stop saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        complete(stop, error);
    }];
}

+ (void) stopWithTour:(Tour *)tour orderIndex:(int)index withCompletion:(void(^)(Stop *stop, NSError *error))complete {
    Stop *stop = [Stop objectWithTour:tour orderIndex:index];
    [stop saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        complete(stop, error);
    }];
}

- (void) deleteStopAndPhotosInBackground {

    PFQuery *query = [Photo query];
    [query whereKey:@"stop" equalTo:self];

    [query findObjectsInBackgroundWithBlock:^(NSArray *photos, NSError *error) {
        for (Photo *photo in photos) {
            [photo deleteInBackground];
        }
        [self deleteInBackground];
    }];
}

@end
