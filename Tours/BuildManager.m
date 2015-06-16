//
//  BuildManager.m
//  Tours
//
//  Created by Gretchen Walker on 6/16/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BuildManager.h"
#import "Tour.h"
#import "Stop.h"

@implementation BuildManager

@synthesize tour;
@synthesize stop;

+ (id)sharedBuildManager {

    static BuildManager *buildManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        buildManager = [self new];
    });
    return buildManager;
}

@end
