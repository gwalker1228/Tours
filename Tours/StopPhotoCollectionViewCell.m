//
//  StopPhotoCollectionViewCell.m
//  Tours
//
//  Created by Adriana Jimenez Mangas on 6/22/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "StopPhotoCollectionViewCell.h"

@interface StopPhotoCollectionViewCell ()



@end


@implementation StopPhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        self.imageView = [[PFImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:self.imageView];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
}

@end



