//
//  DesignableLabel2.m
//  Tours
//
//  Created by Adriana Jimenez Mangas on 6/26/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "DesignableLabel2.h"

@implementation DesignableLabel2

- (void)setUp {

    //UIColor *color1 = [UIColor colorWithRed:252/255.0f green:255/255.0f blue:245/255.0f alpha:1.0];
    //UIColor *veryLightGrayColor = [UIColor colorWithRed:224/255.0f green:224/255.0f blue:224/255.0 alpha:1];

    self.font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:18];

//    self.layer.borderWidth = 0.5;
//    self.layer.borderColor = veryLightGrayColor.CGColor;
//    self.layer.cornerRadius = self.bounds.size.height / 7.0;

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
