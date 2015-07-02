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

    UIColor *color5 = [UIColor colorWithRed:25/255.0f green:52/255.0f blue:65/255.0f alpha:1.0];
    UIColor *veryLightGrayColor = [UIColor colorWithRed:224/255.0f green:224/255.0f blue:224/255.0 alpha:1];

    self.font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:16];
    self.textColor = color5;
    self.backgroundColor = [UIColor whiteColor];

    self.layer.borderWidth = 0.5;
    self.layer.borderColor = veryLightGrayColor.CGColor;

    self.layer.cornerRadius = self.bounds.size.height / 8.0;
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
