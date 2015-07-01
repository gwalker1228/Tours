//
//  TourTableViewCell.m
//  Tours
//
//  Created by Mark Porcella on 6/17/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "TourTableViewCell.h"
#import "IndexedPhotoCollectionView.h"
#import "IndexedPhotoCollectionViewCell.h"
#import "RateView.h"

@interface TourTableViewCell ()

@property (nonatomic) TourDetailView *mainView;
@property (nonatomic) UIButton *publishButton;

@end

@implementation TourTableViewCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    self.superviewWidth = size.width;
    self.superviewHeight = size.height;

    self.mainView = [[TourDetailView alloc] initWithFrame:CGRectMake(0, 0, self.superviewWidth, self.superviewHeight)];
    [self addSubview:self.mainView];
    //   [self.contentView addSubview:self.mainView];
    [self bringSubviewToFront:self.mainView];

    return self;
}

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath {

    [self.mainView setCollectionViewDataSourceDelegate:dataSourceDelegate indexPath:indexPath];
}


- (void)setTitle:(NSString *)title {

    _title = title;
    self.mainView.titleLabel.text = title;
}

- (void)setSummary:(NSString *)summary {

    _summary = summary;
    self.mainView.summaryLabel.text = summary;
}

- (void)setTotalDistance:(float)totalDistance {
    _totalDistance = totalDistance;
    self.mainView.totalDistanceLabel.text = [NSString stringWithFormat:@"Total Distance: %.2f mi", totalDistance];
}

- (void)setEstimatedTime:(float)estimatedTime {
    _estimatedTime = estimatedTime;
    self.mainView.estimatedTimeLabel.text = [NSString stringWithFormat:@"Estimated Time: %g min", estimatedTime];
}


- (void)setDistanceFromCurrentLocation:(NSString *)distanceFromCurrentLocation {
    _distanceFromCurrentLocation = distanceFromCurrentLocation;
    self.mainView.distanceFromCurrentLocationLabel.text = distanceFromCurrentLocation ? [NSString stringWithFormat:@"%@ from you", distanceFromCurrentLocation] : @"";
}

- (void)setRating:(float)rating {
    _rating = rating;

    self.mainView.ratingLabel.text = @"Avg. Rating: ";
    self.mainView.ratingView.rating = rating;
}

- (void)setTitle:(NSString *)title summary:(NSString *)summary {
    self.mainView.titleLabel.text = title;
    self.mainView.summaryLabel.text = summary;
    [self.mainView reloadInputViews];
}

- (void)showPublishButton {

    CGFloat publishButtonX = self.mainView.distanceFromCurrentLocationLabel.frame.origin.x;
    CGFloat publishButtonY = self.mainView.totalDistanceLabel.frame.origin.y;
    CGFloat publishButtonWidth = self.mainView.distanceFromCurrentLocationLabel.frame.size.width;
    CGFloat publishButtonHeight = self.mainView.titleLabel.frame.size.height;

    self.publishButton = [[UIButton alloc] initWithFrame:CGRectMake(publishButtonX, publishButtonY, publishButtonWidth, publishButtonHeight)];

    UIColor *color1 = [UIColor colorWithRed:252/255.0f green:255/255.0f blue:245/255.0f alpha:1.0];
    UIColor *color3 = [UIColor colorWithRed:145/255.0f green:170/255.0f blue:157/255.0f alpha:1.0];

    self.publishButton.tintColor = color1;
    self.publishButton.backgroundColor = color3;
    self.publishButton.titleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:18];
    self.publishButton.layer.cornerRadius = 5;
    [self.publishButton setTitle:@"Publish Tour" forState:UIControlStateNormal];
    [self.publishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.mainView.ratingView removeFromSuperview];

    [self.publishButton addTarget:self action:@selector(onPublishTourButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    [self.mainView addSubview:self.publishButton];

}

- (void)onPublishTourButtonPressed {

    [self.delegate tourTableViewCell:self publishTourButtonPressedForTour:self.tour];
}

@end



