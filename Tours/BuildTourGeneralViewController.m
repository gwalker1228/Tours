//
//  BuildTourGeneralViewController.m
//  Tours
//
//  Created by Mark Porcella on 6/14/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BuildTourGeneralViewController.h"


@interface BuildTourGeneralViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *buildTourGeneralTitle;
@property (weak, nonatomic) IBOutlet UITextView *buildTourGeneralSummary;

@end

@implementation BuildTourGeneralViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupView];
}

- (void)setupView {

    self.buildTourGeneralTitle.text = self.tour.title;
    self.buildTourGeneralSummary.text = self.tour.summary;
    self.buildTourGeneralTitle.delegate = self;
    self.buildTourGeneralSummary.delegate = self;

    self.buildTourGeneralSummary.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:.4].CGColor;
    self.buildTourGeneralSummary.layer.borderWidth = .5;
    self.buildTourGeneralSummary.layer.cornerRadius = 5;
    self.buildTourGeneralSummary.backgroundColor = [UIColor whiteColor];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
}

- (void)viewWillDisappear:(BOOL)animated {

    self.tour.title = self.buildTourGeneralTitle.text;
    self.tour.summary = self.buildTourGeneralSummary.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [[self view] endEditing:YES];
    return true;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{

    if ([text isEqualToString:@"\n"]) {

        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}



@end
