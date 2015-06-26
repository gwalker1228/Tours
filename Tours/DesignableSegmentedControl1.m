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

    // colors from lighter to darker
    UIColor *color1 = [UIColor colorWithRed:252/255.0f green:255/255.0f blue:245/255.0f alpha:1.0];
    //UIColor *color2 = [UIColor colorWithRed:209/255.0f green:219/255.0f blue:189/255.0f alpha:1.0];
    UIColor *color3 = [UIColor colorWithRed:145/255.0f green:170/255.0f blue:157/255.0f alpha:1.0];
    //UIColor *color4 = [UIColor colorWithRed:62/255.0f green:96/255.0f blue:111/255.0f alpha:1.0];
    //UIColor *color5 = [UIColor colorWithRed:25/255.0f green:52/255.0f blue:65/255.0f alpha:1.0];

    self.tintColor = color1;
    self.backgroundColor = color3;

    //self.layer.cornerRadius = self.bounds.size.height / 2.0;
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
