//
//  PhotoPopup.m
//  Tours
//
//  Created by Gretchen Walker on 6/29/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "PhotoPopup.h"
#import "PhotoFlag.h"
#import "Photo.h"
#import "User.h"

@interface PhotoPopup () <UIAlertViewDelegate>

@property UIImageView *imageView;
@property UIView *backgroundView;
@property UIView *captionView;
@property UILabel *titleLabel;
@property UILabel *summaryLabel;
@property UIButton *flagButton;
@property NSString *flagButtonTitle;
@property BOOL editable;
@property Photo *photo;

@end

@implementation PhotoPopup


+ (void)popupWithImage:(UIImage *)image inView:(UIView *)view {

    PhotoPopup *popup = [[PhotoPopup alloc] initWithFrame:view.frame];

    popup.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    popup.imageView.image = image;
    popup.imageView.frame = CGRectMake(view.center.x, view.center.y, 0, 0);

    CGFloat imageWidth = view.bounds.size.width;
    CGFloat originx = view.center.x - (imageWidth / 2);
    CGFloat originy = view.center.y - (imageWidth / 2);

    popup.backgroundView = [[UIView alloc] initWithFrame:view.bounds];
    popup.backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];

    [popup addSubview:popup.backgroundView];
    [view addSubview:popup];

    [UIView animateWithDuration:.5 animations:^{

        [popup addSubview:popup.imageView];
        popup.imageView.frame = CGRectMake(originx, originy, imageWidth, imageWidth);
        [popup bringSubviewToFront:popup.imageView];

    } completion:^(BOOL finished) {

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:popup action:@selector(onViewTapped)];

        [popup.imageView addGestureRecognizer:tap];
        [popup.backgroundView addGestureRecognizer:tap];
    }];
}

+ (void)popupWithImage:(UIImage *)image photo:(Photo *)photo inView:(UIView *)view editable:(BOOL)editable delegate:(id<PhotoPopupDelegate>)delegate {

    PhotoPopup *popup = [[PhotoPopup alloc] initWithFrame:view.frame];

    popup.photo = photo;
    popup.editable = editable;
    popup.delegate = delegate;

    CGFloat margin = 8;

    CGFloat imageWidth = view.bounds.size.width;
    CGFloat imageX = view.center.x - (imageWidth / 2);
    CGFloat imageY = view.center.y - (imageWidth / 2);

    CGFloat captionX = imageX;
    CGFloat captionY = imageY + imageWidth;
    CGFloat captionWidth = imageWidth;
    CGFloat captionHeight = 60;

    CGFloat flagButtonWidth = captionWidth / 2.5;
    CGFloat flagButtonHeight = captionHeight / 4;
    CGFloat flagButtonX = captionWidth - (flagButtonWidth + margin);
    CGFloat flagButtonY = captionY + margin;

    CGFloat titleX = captionX + margin;
    CGFloat titleY = captionY + margin;
    CGFloat titleWidth = captionWidth - flagButtonWidth - margin * 2;
    CGFloat titleHeight = captionHeight / 4;

    CGFloat summaryX = titleX;
    CGFloat summaryY = titleY + titleHeight;
    CGFloat summaryWidth = captionWidth - margin * 2;
    CGFloat summaryHeight = captionHeight - titleHeight - margin;

    popup.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    popup.imageView.image = image;
    popup.imageView.frame = CGRectMake(view.center.x, view.center.y, 0, 0);

    popup.backgroundView = [[UIView alloc] initWithFrame:view.bounds];
    popup.backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];

    popup.captionView = [[UIView alloc] initWithFrame:CGRectMake(view.center.x, view.center.y, 0, 0)];
    popup.captionView.backgroundColor = [UIColor whiteColor];

    popup.flagButton = [[UIButton alloc] initWithFrame:popup.captionView.frame];
    popup.flagButton.titleLabel.numberOfLines = 0;

    popup.titleLabel = [[UILabel alloc] initWithFrame:popup.captionView.frame];
    popup.summaryLabel = [[UILabel alloc] initWithFrame:popup.captionView.frame];

    popup.titleLabel.textColor = [UIColor colorWithRed:25/255.0 green:52/255.0 blue:65/255.0 alpha:1.0];
    popup.summaryLabel.textColor = [UIColor colorWithRed:25/255.0 green:52/255.0 blue:65/255.0 alpha:1.0];

    if (popup.editable) {
        [popup.flagButton setTitle:@"Edit Photo" forState:UIControlStateNormal];
        [popup.flagButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [popup.flagButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [popup.flagButton.titleLabel setTextAlignment:NSTextAlignmentRight];
    }
    else {
        popup.flagButtonTitle = @"Flag as inappropriate";
        PFQuery *flagQuery = [PhotoFlag query];

        [flagQuery whereKey:@"user" equalTo:[User currentUser]];
        [flagQuery whereKey:@"photo" equalTo:photo];

        [flagQuery findObjectsInBackgroundWithBlock:^(NSArray *flags, NSError *error) {

            [popup.flagButton.titleLabel setFont:[UIFont systemFontOfSize:12]];

            if (!error && flags.count > 0) {
                [popup.flagButton setTitle:@"Flagged as inappropriate" forState:UIControlStateNormal];
                [popup.flagButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                popup.flagButton.enabled = NO;
            }
            else {
                [popup.flagButton setTitle:@"Flag as inappropriate" forState:UIControlStateNormal];
                [popup.flagButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            }
        }];

    }
    [popup addSubview:popup.backgroundView];
    [popup addSubview:popup.imageView];
    [popup addSubview:popup.captionView];
    [popup addSubview:popup.titleLabel];
    [popup addSubview:popup.summaryLabel];
    [popup addSubview:popup.flagButton];

    [view addSubview:popup];

    [UIView animateWithDuration:.5 animations:^{


        popup.imageView.frame = CGRectMake(imageX, imageY, imageWidth, imageWidth);
        popup.captionView.frame = CGRectMake(captionX, captionY, captionWidth, captionHeight);
        popup.titleLabel.frame = CGRectMake(titleX, titleY, titleWidth, titleHeight);
        popup.summaryLabel.frame = CGRectMake(summaryX, summaryY, summaryWidth, summaryHeight);
        popup.flagButton.frame = CGRectMake(flagButtonX, flagButtonY, flagButtonWidth, flagButtonHeight);

    } completion:^(BOOL finished) {

        popup.titleLabel.text = photo.title;
        popup.summaryLabel.text = photo.summary;

//        [popup.flagButton setTitle:popup.flagButtonTitle forState:UIControlStateNormal];
//        [popup.flagButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//        [popup.flagButton.titleLabel setFont:[UIFont systemFontOfSize:12]];

        popup.titleLabel.font = [UIFont systemFontOfSize:14];
        popup.summaryLabel.font = [UIFont systemFontOfSize:14];

        if (popup.editable) {
            [popup.flagButton addTarget:popup action:@selector(editPhotoPressed) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            [popup.flagButton addTarget:popup action:@selector(flagAsInappropriate) forControlEvents:UIControlEventTouchUpInside];
        }

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:popup action:@selector(onViewTapped)];

        [popup.imageView addGestureRecognizer:tap];
        [popup.backgroundView addGestureRecognizer:tap];
        [popup.delegate photoPopup:popup viewDidAppear:popup.photo];
    }];
}

- (void)onViewTapped {

    [self.titleLabel removeFromSuperview];
    [self.summaryLabel removeFromSuperview];

    [UIView animateWithDuration:0.1 animations:^{

        self.imageView.frame = CGRectMake(self.superview.center.x, self.superview.center.y, 1, 1);
        self.backgroundView.frame = CGRectMake(self.superview.center.x, self.superview.center.y, 1, 1);

    } completion:^(BOOL finished) {

        [self removeFromSuperview];
        [self.delegate photoPopup:self viewDidDisappear:self.photo];
    }];
}

- (void)reloadViews {

    self.titleLabel.text = self.photo.title;
    self.summaryLabel.text = self.photo.summary;

    [self.photo.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {

        if (!error) {
            self.imageView.image = [UIImage imageWithData:data];
        }
    }];
}

- (void)flagAsInappropriate {

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Flag this photo as inappropriate?" message:@"(Note: You will not be able to undo this action)" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Proceed", nil];

    alertView.delegate = self;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 1) {

        PhotoFlag *flag = [PhotoFlag object];
        flag.user = [User currentUser];
        flag.photo = self.photo;

        [flag saveInBackground];

        [self.flagButton setTitle:@"Flagged as inappropriate" forState:UIControlStateNormal];
        [self.flagButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        self.flagButton.enabled = NO;
        [self.flagButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    }
}

- (void)editPhotoPressed {

    [self.delegate photoPopup:self editPhotoButtonPressed:self.photo];
}

@end
