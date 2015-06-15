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
@dynamic description;
@dynamic image;
@dynamic stop;

- (NSString * __nonnull)parseClassName {
    return @"Photo";
}

+ (instancetype) ojbectWithImage:(UIImage *)image stop:(Stop *)stop title:(NSString *)title description:(NSString *)description {

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
    photo.description = description;

    return photo;
}

+ (void) photoWithImage:(UIImage *)image stop:(Stop *)stop title:(NSString *)title description:(NSString *)description withCompletion:(void(^)(Photo *photo, NSError *error))complete {

    Photo *photo = [Photo ojbectWithImage:image stop:stop title:title description:description];

    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        complete(photo, error);
    }];
}


@end
