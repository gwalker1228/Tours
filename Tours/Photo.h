//
//  Photo.h
//  Tours
//
//  Created by Mark Porcella on 6/15/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@class Stop;

@interface Photo : PFObject <PFSubclassing>

@property NSString *title;
@property NSString *summary;
@property PFFile *image;
@property Stop *stop;

+ (void) photoWithImage:(UIImage *)image stop:(Stop *)stop title:(NSString *)title description:(NSString *)description withCompletion:(void(^)(Photo *photo, NSError *error))complete;

@end
