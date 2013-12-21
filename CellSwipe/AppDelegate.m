//
//  AppDelegate.m
//  CellSwipe
//
//  Created by Parag Shah on 12/16/13.
//  Copyright (c) 2013 www.paragshah.com. All rights reserved.
//

#import "AppDelegate.h"
#import "CSTableViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    CSTableViewController *tvc = [[CSTableViewController alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:tvc];

    self.window.rootViewController = nc;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    return YES;
}

@end
