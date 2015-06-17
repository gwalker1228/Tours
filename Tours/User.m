//
//  User.m
//  Tours
//
//  Created by Adriana Jimenez Mangas on 6/17/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//


#import <Parse/PFObject+Subclass.h>
#import "User.h"

@implementation User

+(instancetype)objectWithUserName:(NSString *)username password:(NSString *)password email:(NSString *)email {

    User *user = [super object];

    user.username = username;
    user.password = password;
    user.email = email;

    return user;
}


+ (void)userWithUserName:(NSString *)username password:(NSString *)password email:(NSString *)email withCompletion:(void (^)(User *))complete {

    User *user = [User objectWithUserName:username password:password email:email];

    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        if (!error) {
            complete(user);
        }
        else {
            NSLog(@"%@", error);
        }
    }];
}

@end



