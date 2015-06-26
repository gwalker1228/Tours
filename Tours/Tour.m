//
//  Tour.m
//  Tours
//
//  Created by Mark Porcella on 6/15/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "Tour.h"
#import "User.h"

@implementation Tour

@dynamic title;
@dynamic summary;
@dynamic creator;
@dynamic totalDistance;
@dynamic estimatedTime;
@dynamic averageRating;

+ (NSString * __nonnull)parseClassName {
    return @"Tour";
}


@end
