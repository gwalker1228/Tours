//
//  TourPhotoCollectionViewCell.m
//  Tours
//
//  Created by Gretchen Walker on 6/23/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "TourPhotoCollectionViewCell.h"

@implementation TourPhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {

        CGFloat photoWidth = frame.size.width - 12;
        CGFloat photoMargin = (frame.size.height - photoWidth) / 2;
        self.imageView = [[PFImageView alloc] initWithFrame:CGRectMake(photoMargin, photoMargin, photoWidth, photoWidth)];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:self.imageView];
    }
    return self;
}


@end
