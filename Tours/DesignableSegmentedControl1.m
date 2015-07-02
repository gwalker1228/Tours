//
//  DesignableSegmentedControl1.m
//  Tours
//
//  Created by Adriana Jimenez Mangas on 6/25/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "DesignableSegmentedControl1.h"

@implementation DesignableSegmentedControl1


- (void)setUp {

    UIColor *color1 = [UIColor colorWithRed:252/255.0f green:255/255.0f blue:245/255.0f alpha:1.0];
    UIColor *color3 = [UIColor colorWithRed:145/255.0f green:170/255.0f blue:157/255.0f alpha:1.0];

    self.tintColor = color1;
    self.backgroundColor = color3;

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
