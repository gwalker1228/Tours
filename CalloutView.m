//
//  CalloutView.m
//  Tours
//
//  Created by Mark Porcella on 6/20/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "CalloutView.h"

@implementation CalloutView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame title:(NSString *)title summary:(NSString *)summary {
    self = [super initWithFrame:frame];

    if (self) {

        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
        titleLabel.text = title; //@"i am label 1";
        [self addSubview:titleLabel];

        UILabel *summaryLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,25, 200, 20)];
        summaryLabel.text = summary;
        [self addSubview:summaryLabel];

    }
    return self;
}
@end
