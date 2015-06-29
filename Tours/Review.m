//
//  Review.m
//  Tours
//
//  Created by Mark Porcella on 6/28/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "Review.h"
#import "Tour.h"
#import "User.h"

@implementation Review

@dynamic tour;
@dynamic user;
@dynamic rating;
@dynamic reviewText;

+ (NSString * __nonnull)parseClassName {
    return @"Review";
}

+ (void) reviewWithUser:(User *)user tour:(Tour *)tour rating:(float)rating reviewText:(NSString *)reviewText withCompletion:(void (^)(Review *review, NSError *error))complete {
    Review *review = [super object];
    review.user = user;
    review.tour = tour;
    review.rating = rating;
    review.reviewText = reviewText;

    [review saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        complete(review, error);
    }];
}



@end
