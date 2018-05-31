//
//  AppDelegate.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/9.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "AppDelegate.h"
#import "RCCRListCollectionViewController.h"
#import "RCCRRongCloudIMManager.h"
#import "RCChatroomWelcome.h"
#import "RCChatroomGift.h"
#import "RCChatroomLike.h"
#import "RCChatroomBarrage.h"
#import "RCChatroomFollow.h"
#import "RCChatroomUserQuit.h"

#define APPKEY @"tdrvipkstfsu5"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] initRongCloud:APPKEY];
    
    //注册自定义消息
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] registerRongCloudMessageType:[RCChatroomWelcome class]];
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] registerRongCloudMessageType:[RCChatroomGift class]];
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] registerRongCloudMessageType:[RCChatroomLike class]];
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] registerRongCloudMessageType:[RCChatroomBarrage class]];
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] registerRongCloudMessageType:[RCChatroomFollow class]];
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] registerRongCloudMessageType:[RCChatroomUserQuit class]];
    RCCRListCollectionViewController *viewController = [[RCCRListCollectionViewController alloc] init];
    
    // 初始化 UINavigationController。
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:viewController];
    
    // 初始化 rootViewController。
    self.window.rootViewController = nav;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
