//
//  AppDelegate.m
//  CJAInvocation
//
//  Created by Carl Jahn on 10.10.13.
//  Copyright (c) 2013 Carl Jahn. All rights reserved.
//

#import "AppDelegate.h"
#import "ExampleViewController.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  // Override point for customization after application launch.
  self.window = [[UIWindow alloc] initWithFrame: [UIScreen mainScreen].bounds ];
  
  self.window.rootViewController = [ExampleViewController new];
  [self.window makeKeyAndVisible];
  
  return YES;
}

@end
