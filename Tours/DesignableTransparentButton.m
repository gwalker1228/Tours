//
//  DesignableButton2.m
//  Tours
//
//  Created by Adriana Jimenez Mangas on 6/25/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "DesignableTransparentButton.h"

@implementation DesignableTransparentButton

- (void)setUp {

    UIColor *color1 = [UIColor colorWithRed:252/255.0f green:255/255.0f blue:245/255.0f alpha:1.0];
    UIColor *color4 = [UIColor colorWithRed:62/255.0f green:96/255.0f blue:111/255.0f alpha:1.0];
    //UIColor *color5 = [UIColor colorWithRed:25/255.0f green:52/255.0f blue:65/255.0f alpha:1.0];

    self.tintColor = color1;
    self.backgroundColor = [color4 colorWithAlphaComponent:0.40];

    self.titleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:15];

    self.layer.borderColor = color1.CGColor;
    self.layer.borderWidth = 0.5;

    self.layer.cornerRadius = self.bounds.size.height / 2.0;
    self.layer.masksToBounds = YES;
}


- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    [self setUp];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUp];
}

@end



