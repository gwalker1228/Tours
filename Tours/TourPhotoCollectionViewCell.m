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

        self.imageView = [[PFImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:self.imageView];
    }
    return self;
}


@end
