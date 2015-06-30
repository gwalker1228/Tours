//
//  PhotoFlag.h
//  Tours
//
//  Created by Gretchen Walker on 6/29/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@class User;
@class Photo;

@interface PhotoFlag : PFObject <PFSubclassing>

@property User *user;
@property Photo *photo;

@end
