//
//  DesignableTextView.m
//  Tours
//
//  Created by Adriana Jimenez Mangas on 6/25/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "DesignableTextView1.h"


@interface DesignableTextView1 ()

@end


@implementation DesignableTextView1

- (void)setUp {

    UIColor *color1 = [UIColor colorWithRed:252/255.0f green:255/255.0f blue:245/255.0f alpha:1.0];

    self.font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:18];
    self.backgroundColor = color1;

    //self.layer.borderWidth = 3.0;
    //self.layer.borderColor = [UIColor redColor].CGColor;

    self.layer.cornerRadius = self.bounds.size.height / 7.0;
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
