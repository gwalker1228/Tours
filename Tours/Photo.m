//
//  Photo.m
//  Tours
//
//  Created by Mark Porcella on 6/15/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "Photo.h"
#import "Stop.h"

@implementation Photo

@dynamic title;
@dynamic summary;
@dynamic image;
@dynamic order;
@dynamic stop;


+ (NSString * __nonnull)parseClassName {
    return @"Photo";
}

+ (instancetype) ojbectWithImage:(UIImage *)image stop:(Stop *)stop title:(NSString *)title summary:(NSString *)summary orderNumber:(NSNumber *)order {

    Photo *photo = [super object];

    CGSize newSize = CGSizeMake(500, 500);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);

    photo.image = [PFFile fileWithData:imageData];
    photo.stop = stop;
    photo.title = title;
    photo.summary = summary;
    photo.order = order;

    return photo;
}

+ (void) photoWithImage:(UIImage *)image stop:(Stop *)stop title:(NSString *)title description:(NSString *)summary orderNumber:(NSNumber *)order withCompletion:(void(^)(Photo *photo, NSError *error))complete {

    Photo *photo = [Photo ojbectWithImage:image stop:stop title:title summary:summary orderNumber:order];

    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        complete(photo, error);
    }];
}


@end
