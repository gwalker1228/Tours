//
//  StopPhotoCollectionViewCell.m
//  Tours
//
//  Created by Adriana Jimenez Mangas on 6/22/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "StopPhotoCollectionViewCell.h"

@interface StopPhotoCollectionViewCell ()

@property (strong, nonatomic) UIImageView *imageView;

@end


@implementation StopPhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.image = [UIImage imageNamed:@"3"];
        [self.contentView addSubview:self.imageView];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
}

@end



