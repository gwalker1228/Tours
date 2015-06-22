//
//  CalloutView.h
//  Tours
//
//  Created by Mark Porcella on 6/20/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalloutView : UIView

- (id)initWithFrame:(CGRect)frame title:(NSString *)title summary:(NSString *)summary;

@property UILabel *title;
@property UILabel *summary;


@end
