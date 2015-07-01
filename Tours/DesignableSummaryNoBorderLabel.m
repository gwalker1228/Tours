//
//  DesignableLabel.m
//  Tours
//
//  Created by Adriana Jimenez Mangas on 6/25/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "DesignableSummaryNoBorderLabel.h"

@implementation DesignableSummaryNoBorderLabel

- (void)setUp {
    UIColor *color5 = [UIColor colorWithRed:25/255.0f green:52/255.0f blue:65/255.0f alpha:1.0];

    self.font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:15];
    self.textColor = color5;
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
