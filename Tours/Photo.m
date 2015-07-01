//
//  Photo.m
//  Tours
//
//  Created by Mark Porcella on 6/15/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "Photo.h"
#import "Stop.h"
#import "Tour.h"
#import "User.h"

@implementation Photo

@dynamic title;
@dynamic summary;
@dynamic image;
@dynamic order;
@dynamic stop;
@dynamic tour;
@dynamic creator;

+ (NSString * __nonnull)parseClassName {
    return @"Photo";
}

+ (instancetype) ojbectWithImage:(UIImage *)image stop:(Stop *)stop tour:(Tour *)tour title:(NSString *)title summary:(NSString *)summary orderNumber:(NSNumber *)order {

    Photo *photo = [super object];

    CGSize newSize = CGSizeMake(500, 500);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);

    photo.image = [PFFile fileWithData:imageData];
    photo.stop = stop;
    photo.tour = tour;
    photo.title = title;
    photo.summary = summary;
    photo.order = order;
    photo.creator = [User currentUser];

    return photo;
}

+ (void) photoWithImage:(UIImage *)image stop:(Stop *)stop tour:(Tour *)tour title:(NSString *)title description:(NSString *)summary orderNumber:(NSNumber *)order withCompletion:(void(^)(Photo *photo, NSError *error))complete {

    Photo *photo = [Photo ojbectWithImage:image stop:stop tour:tour title:title summary:summary orderNumber:order];

    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        complete(photo, error);
    }];
}

- (void) updatePhoto:(Photo *)photo photoWithImage:(UIImage *)image title:(NSString *)title description:(NSString *)summary withCompletion:(void(^)(Photo *photo, NSError *error))complete {

    CGSize newSize = CGSizeMake(500, 500);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);

    photo.image = [PFFile fileWithData:imageData];
    photo.title = title;
    photo.summary = summary;

    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        complete(photo, error);
    }];

}







@end
