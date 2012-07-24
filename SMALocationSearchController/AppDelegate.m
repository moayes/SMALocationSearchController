//
//  AppDelegate.m
//  SMALocationSearchController
//
//  Created by Soheil Azarpour on 7/24/12.
//  Copyright (c) 2012 iOS Developer. All rights reserved.
//

#import "AppDelegate.h"
#import "SMALocationSearchController.h"


@implementation AppDelegate

@synthesize window = _window;


- (void)dealloc {
    [_window release];
    [super dealloc];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    
    SMALocationSearchController *controller = [[SMALocationSearchController alloc] initWithNibName:@"SMALocationSearchView" bundle:nil];
    self.window.rootViewController = controller;
    [controller release];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
