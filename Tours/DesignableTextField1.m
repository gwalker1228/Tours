//
//  DesignableTextField1.m
//  Tours
//
//  Created by Adriana Jimenez Mangas on 6/25/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "DesignableTextField1.h"

@implementation DesignableTextField1

- (void)setUp {

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
