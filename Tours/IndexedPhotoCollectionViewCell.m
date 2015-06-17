//
//  IndexedPhotoCollectionViewCell.m
//  Tours
//
//  Created by Gretchen Walker on 6/16/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "IndexedPhotoCollectionViewCell.h"

@implementation IndexedPhotoCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];

    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.contentView addSubview:self.imageView];

    return self;
}

@end
