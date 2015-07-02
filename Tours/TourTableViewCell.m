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
#import "PhotoPopup.h"

@interface TourTableViewCell ()

@property (nonatomic) TourDetailView *mainView;
@property (nonatomic) UIButton *publishButton;
@property (nonatomic) UIButton *deleteButton;

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
    self.mainView.totalDistanceLabel.text = [NSString stringWithFormat:@"Total Distance: %.1f mi", totalDistance];
}

- (void)setEstimatedTime:(float)estimatedTime {
    _estimatedTime = estimatedTime;
    self.mainView.estimatedTimeLabel.text = [NSString stringWithFormat:@"Est. Time: %@", getTimeStringFromETAInMinutes(estimatedTime)];
}


- (void)setDistanceFromCurrentLocation:(NSString *)distanceFromCurrentLocation {
    _distanceFromCurrentLocation = distanceFromCurrentLocation;
    self.mainView.distanceFromCurrentLocationLabel.text = distanceFromCurrentLocation ? [NSString stringWithFormat:@"%@ from you", distanceFromCurrentLocation] : @"";
}

- (void)setRating:(float)rating {
    _rating = rating;

    self.mainView.ratingLabel.text = @"Avg. Rating: ";
    self.mainView.ratingView.rating = rating;
//    [self.mainView bringSubviewToFront:self.mainView.ratingView];
    [self.mainView addSubview: self.mainView.ratingView];
}

- (void)setTitle:(NSString *)title summary:(NSString *)summary {
    self.mainView.titleLabel.text = title;
    self.mainView.summaryLabel.text = summary;
    [self.mainView reloadInputViews];
}

- (void)showDeleteButton {

    CGFloat deleteButtonX = self.mainView.titleLabel.frame.origin.x + self.mainView.titleLabel.frame.size.width;
    CGFloat deleteButtonY = 0;
    CGFloat deleteButtonWidth = self.mainView.frame.size.width - deleteButtonX - 8;
    CGFloat deleteButtonHeight = self.mainView.titleLabel.frame.size.height;

    self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(deleteButtonX, deleteButtonY, deleteButtonWidth, deleteButtonHeight)];

    [self.deleteButton setTitle:@"X" forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    self.deleteButton.titleLabel.font = [UIFont systemFontOfSize:20];

    [self.deleteButton addTarget:self action:@selector(onDeleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    [self.mainView addSubview:self.deleteButton];
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

    [self.publishButton addTarget:self action:@selector(onPublishTourButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    [self.mainView addSubview:self.publishButton];

}

- (void) clearVariableViews {

    [self.deleteButton removeFromSuperview];
    [self.publishButton removeFromSuperview];
    self.mainView.distanceFromCurrentLocationLabel.text = @"";
    [self.mainView.ratingView removeFromSuperview];
//    [self.mainView sendSubviewToBack:self.mainView.ratingView];
    self.mainView.ratingLabel.text = @"";

}

- (void)onDeleteButtonPressed {
    [self.delegate tourTableViewCell:self deleteTourButtonPressedForTour:self.tour];
}

- (void)onPublishTourButtonPressed {

    [self.delegate tourTableViewCell:self publishTourButtonPressedForTour:self.tour];
}

@end



