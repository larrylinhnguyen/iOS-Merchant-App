//
//  AppDelegate.m
//  Merchant
//
//  Created by User on 10/21/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "AppDelegate.h"

#import "MMDrawerController.h"

#import "UIColor+Utilities.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

static NSString *const kBCMCenterViewControllerId = @"BCMCenterViewControllerId";
static NSString *const kBCMPOSNavigationId = @"BCMPOSNavigationId";
static NSString *const kBCMSideNavigationViewControllerId = @"BCMSideNavigationViewControllerId";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *centerViewController = [mainStoryboard instantiateViewControllerWithIdentifier:kBCMPOSNavigationId];
    UIViewController *leftViewController = [mainStoryboard instantiateViewControllerWithIdentifier:kBCMSideNavigationViewControllerId];
    
    self.drawerController = [[MMDrawerController alloc] initWithCenterViewController:centerViewController leftDrawerViewController:leftViewController];
    self.drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    self.drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureModeAll;

    [self styleNavigationBar];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:self.drawerController];
    [self.window makeKeyAndVisible];
    
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

// Global Styling
- (void)styleNavigationBar
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHexValue:BCM_BLUE]];
}

@end
