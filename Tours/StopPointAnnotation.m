//
//  StopPointAnnotation.m
//  Tours
//
//  Created by Gretchen Walker on 6/15/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "StopPointAnnotation.h"
#import "Stop.h"
#import <Parse/Parse.h>


@implementation StopPointAnnotation

-(instancetype)initWithLocation:(CLLocation *)location forStop:(Stop *)stop {

    self = [super init];

    self.coordinate = location.coordinate;
    self.stop = stop;

    return self;
}

-(instancetype)initWithStop:(Stop *)stop {

    self = [super init];

    self.coordinate = CLLocationCoordinate2DMake(stop.location.latitude, stop.location.longitude);
    self.stop = stop;

    return self;
}

@end
