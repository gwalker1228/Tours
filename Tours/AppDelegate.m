//
//  AppDelegate.m
//  Tours
//
//  Created by Mark Porcella on 6/14/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "Tour.h"
#import "Stop.h"
#import "Photo.h"
#import "Review.h"
#import "PhotoFlag.h"
#import "ReviewFlag.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // [Optional] Power your app with Local Datastore. For more info, go to

    [Parse enableLocalDatastore];

    [Tour registerSubclass];
    [Stop registerSubclass];
    [Photo registerSubclass];
    [Review registerSubclass];
    [PhotoFlag registerSubclass];
    [ReviewFlag registerSubclass];

    // Initialize Parse.
    [Parse setApplicationId:@"utT2GUSlYKCwDjiPcGHetnMW7MlDSEj3vpljW3ZI"
                  clientKey:@"oDpWWcqcbX01oafSLvFm6yt7ij6eWqNVHhME0NeD"];

    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
