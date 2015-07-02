//
//  ReviewFlag.m
//  Tours
//
//  Created by Gretchen Walker on 7/2/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "ReviewFlag.h"
#import "Review.h"
#import "User.h"
#import "Tour.h"

@implementation ReviewFlag

@dynamic user;
@dynamic review;
@dynamic tour;

+ (NSString * __nonnull)parseClassName {
    return @"ReviewFlag";
}

@end
