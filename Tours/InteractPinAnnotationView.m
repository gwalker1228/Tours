//
//  InteractPinAnnotationView.m
//  Tours
//
//  Created by Mark Porcella on 6/21/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "InteractPinAnnotationView.h"

@implementation InteractPinAnnotationView


    // This is required to allow touch interactions with view on top of mapView
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event
{
    UIView* hitView = [super hitTest:point withEvent:event];
    if (hitView != nil)
    {
        [self.superview bringSubviewToFront:self];
    }
    return hitView;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    CGRect rect = self.bounds;
    BOOL isInside = CGRectContainsPoint(rect, point);
    if(!isInside)
    {
        for (UIView *view in self.subviews)
        {
            isInside = CGRectContainsPoint(view.frame, point);
            if(isInside)
                break;
        }
    }
    return isInside;
}

@end
