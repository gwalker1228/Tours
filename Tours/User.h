//
//  User.h
//  Tours
//
//  Created by Adriana Jimenez Mangas on 6/17/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <Parse/Parse.h>

@interface User : PFUser <PFSubclassing>

+ (void)userWithUserName:(NSString *)username password:(NSString *)password email:(NSString *)email withCompletion:(void(^)(User *user))complete;

@end
