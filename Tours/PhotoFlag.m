//
//  PhotoFlag.m
//  Tours
//
//  Created by Gretchen Walker on 6/29/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "PhotoFlag.h"
#import "User.h"
#import "Photo.h"

@implementation PhotoFlag

@dynamic user;
@dynamic photo;

+ (NSString * __nonnull)parseClassName {
    return @"PhotoFlag";
}

@end
