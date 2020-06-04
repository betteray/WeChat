//
//  AppDelegate.m
//  WXDemo
//
//  Created by ray on 2018/9/13.
//  Copyright © 2018 ray. All rights reserved.
//

#import "AppDelegate.h"
#import "WeChatClient.h"
#import "DNSFetcher.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "ClientCheckDataFetcher.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "CUtility.h"
#import "FPService.h"

#import "AuthService.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    // Configure CocoaLumberjack
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

#if PROTOCOL_FOR_IOS
    LogVerbose(@"PROTOCOL_FOR_IOS Client Version: %@(%x)", IVERSION, [CUtility numberVersionOf:IVERSION]);
#elif PROTOCOL_FOR_ANDROID
    LogVerbose(@"PROTOCOL_FOR_ANDROID Client Version: %x", AVERSION);
#endif
    
    [[WeChatClient sharedClient] start];
    [DNSFetcher fetchAndSaveToDB];
   
    [self tryFreshDeviceToken];
    [self autoAuthIfCould];

    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    
    return YES;
}

- (void)tryFreshDeviceToken {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BOOL isExist = [NSData dataWithContentsOfFile:DEVICE_TOKEN_PATH].length > 0;
        if (!isExist) {
            [FPService initFP];
        } else {
            if ([DBManager autoAuthKey].data.length == 0) {
                [FPService fpfresh:NO];
            }
        }
    });
}

- (void)autoAuthIfCould {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        AutoAuthKeyStore *autoAuthKeyStore = [DBManager autoAuthKey];
        if ([autoAuthKeyStore.data length] > 0) {
            [AuthService autoAuthWithRootViewController:(UINavigationController *)self.window.rootViewController];
        }
    });
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
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
