//
//  SummaryTextView.h
//  Tours
//
//  Created by Gretchen Walker on 6/23/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SummaryTextViewDelegate <UITextViewDelegate>

@optional

@end

@interface SummaryTextView : UITextView {

    id<SummaryTextViewDelegate> delegate;
}

@property BOOL truncated;

@end
