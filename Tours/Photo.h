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
@class Tour;
@class User;

@interface Photo : PFObject <PFSubclassing>

@property NSString *title;
@property NSString *summary;
@property PFFile *image;
@property NSNumber *order;
@property Stop *stop;
@property Tour *tour;
@property User *creator;

+ (void) photoWithImage:(UIImage *)image stop:(Stop *)stop tour:(Tour *)tour title:(NSString *)title description:(NSString *)description orderNumber:(NSNumber *)order withCompletion:(void(^)(Photo *photo, NSError *error))complete;

- (void) updatePhoto:(Photo *)photo photoWithImage:(UIImage *)image title:(NSString *)title description:(NSString *)summary withCompletion:(void(^)(Photo *photo, NSError *error))complete;

@end
