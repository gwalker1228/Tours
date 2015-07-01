//
//  SummaryTextView.m
//  Tours
//
//  Created by Gretchen Walker on 6/23/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "SummaryTextView.h"

@interface SummaryTextView ()

@property CGRect truncatedFrame;
@property NSString *fullText;

@end

@implementation SummaryTextView


-(instancetype)initWithFrame:(CGRect)frame text:(NSString *)text {

    self = [super initWithFrame:frame];

    self.truncated = YES;
    self.truncatedFrame = frame;
    self.fullText = text;
    self.text = text;

    return self;
}

-(NSString *)truncateFullText {

    NSMutableString *truncatedText = [self.fullText mutableCopy];

    return truncatedText;
}

@end
