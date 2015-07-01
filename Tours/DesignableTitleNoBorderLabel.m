//
//  DesignableLabel2.m
//  Tours
//
//  Created by Adriana Jimenez Mangas on 6/26/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "DesignableTitleNoBorderLabel.h"

@implementation DesignableTitleNoBorderLabel

- (void)setUp {

    UIColor *color5 = [UIColor colorWithRed:25/255.0f green:52/255.0f blue:65/255.0f alpha:1.0];

    self.font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:18];
    self.textColor = color5;

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
