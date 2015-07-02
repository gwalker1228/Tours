//
//  Tour.m
//  Tours
//
//  Created by Mark Porcella on 6/15/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "Tour.h"
#import "User.h"
#import "Stop.h"
#import "Review.h"

@implementation Tour

@dynamic title;
@dynamic summary;
@dynamic creator;
@dynamic totalDistance;
@dynamic estimatedTime;
@dynamic averageRating;
@dynamic published;

+ (NSString * __nonnull)parseClassName {
    return @"Tour";
}

- (void)deleteTourAndAssociatedObjectsInBackground {

    PFQuery *reviewsQuery = [Review query];
    [reviewsQuery whereKey:@"tour" equalTo:self];

    [reviewsQuery findObjectsInBackgroundWithBlock:^(NSArray *reviews, NSError *error) {

        PFQuery *stopsQuery = [Stop query];
        [stopsQuery whereKey:@"tour" equalTo:self];

        [stopsQuery findObjectsInBackgroundWithBlock:^(NSArray *stops, NSError *error) {
            for (Stop *stop in stops) {
                [stop deleteStopAndPhotosInBackground];
            }
            for (Review *review in reviews) {
                [review deleteInBackground];
            }
            [self deleteInBackground];
        }];
    }];
}
@end
