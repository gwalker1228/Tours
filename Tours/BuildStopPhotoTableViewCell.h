//
//  BuildStopPhotoTableViewCell.h
//  Tours
//
//  Created by Mark Porcella on 6/15/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuildStopPhotoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *buildStopPhotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *buildStopPhotoTitle;
@property (weak, nonatomic) IBOutlet UILabel *buildStopPhotoSummary;

@end
