//
//  LoginViewController.m
//  Tours
//
//  Created by Adriana Jimenez Mangas on 6/17/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "User.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)onLoginButtonPressed:(UIButton *)sender {
    [User logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {

        if (!error) {
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry!" message:@"Invalid Username or Password" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];

            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];        }
    }];
}


@end
