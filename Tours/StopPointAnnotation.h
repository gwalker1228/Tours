//
//  StopPointAnnotation.h
//  Tours
//
//  Created by Gretchen Walker on 6/15/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <MapKit/MapKit.h>


@class Stop;

@interface StopPointAnnotation : MKPointAnnotation

@property Stop *stop;


-(instancetype)initWithLocation:(CLLocation *)location forStop:(Stop *)stop;

@end
