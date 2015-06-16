//
//  BuildManager.h
//  Tours
//
//  Created by Gretchen Walker on 6/16/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Tour;
@class Stop;

@interface BuildManager : NSObject

@property (nonatomic, retain) Tour *tour;
@property (nonatomic, retain) Stop *stop;

+ (id)sharedBuildManager;

@end
