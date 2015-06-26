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
    self.font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:18];
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
