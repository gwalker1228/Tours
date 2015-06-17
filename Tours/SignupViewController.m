//
//  SignupViewController.m
//  Tours
//
//  Created by Adriana Jimenez Mangas on 6/17/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "SignupViewController.h"
#import <Parse/Parse.h>
#import "User.h"

@interface SignupViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)onSignupButtonPressed:(UIButton *)sender {

    NSString *username = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *email = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if (username.length == 0 || password.length == 0 || email.length == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:@"Make sure you enter a username, password and email" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];

        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {

        [User userWithUserName:self.usernameTextField.text password:self.passwordTextField.text email:self.emailTextField.text withCompletion:^(User *user) {

            [user signUp];
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}


@end
