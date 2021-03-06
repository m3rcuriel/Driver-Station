//
//  AppDelegate.m
//  Driver Station
//
//  Created by Connor on 2/13/14.
//  Copyright (c) 2014 Connor Christie. All rights reserved.
//

#import "AppDelegate.h"

#define IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    struct FRCCommonControlData *data = IPAD ? [((iMainViewController *) self.mainController) getOutputPacket] : [((MainViewController *) self.mainController) getOutputPacket];
    
    if (self.state == RobotDisabled)
    {
        data->control += 0x20;
    } else if (self.state == RobotEnabled || self.state == RobotWatchdogNotFed || self.state == RobotAutonomous)
    {
        data->control -= 0x20;
    }
    
    if (IPAD)
        [((iMainViewController *)self.mainController) updateAndSend];
    else
        [((MainViewController *)self.mainController) updateAndSend];
    
    NSLog(@"Exiting app, sending disable");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
