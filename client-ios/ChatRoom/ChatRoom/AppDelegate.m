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
#import "RCChatroomStart.h"
#import "RCChatroomEnd.h"
#import "RCChatroomUserBan.h"
#import "RCChatroomUserUnBan.h"
#import "RCChatroomUserBlock.h"
#import "RCChatroomUserUnBlock.h"
#import "RCChatroomNotification.h"
#import <RongRTCLib/RongRTCLib.h>
#import "RCCRLiveHttpManager.h"

#import "RCCRUtilities.h"
#import "RCChatRoomLiveCommand.h"
#import "RCChatRoomNotiAllMessage.h"
#import <Bugly/Bugly.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     BuglyConfig *config = [[BuglyConfig alloc] init];
    #ifdef DEBUG
        config.channel = @"Debug";
    #else
        config.channel = @"Release";
    #endif
        
        [Bugly startWithAppId:@"6a70b5f85e" config:config];
        [Bugly setUserIdentifier:[UIDevice currentDevice].name];
        // 自动化测试取消重定向
    //注册自定义消息
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] registerRongCloudMessageType:[RCChatroomWelcome class]];
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] registerRongCloudMessageType:[RCChatroomGift class]];
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] registerRongCloudMessageType:[RCChatroomLike class]];
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] registerRongCloudMessageType:[RCChatroomBarrage class]];
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] registerRongCloudMessageType:[RCChatroomFollow class]];
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] registerRongCloudMessageType:[RCChatroomUserQuit class]];
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] registerRongCloudMessageType:[RCChatroomStart class]];
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] registerRongCloudMessageType:[RCChatroomEnd class]];
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] registerRongCloudMessageType:[RCChatroomUserBan class]];
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] registerRongCloudMessageType:[RCChatroomUserUnBan class]];
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] registerRongCloudMessageType:[RCChatroomUserBlock class]];
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] registerRongCloudMessageType:[RCChatroomUserUnBlock class]];
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] registerRongCloudMessageType:[RCChatroomNotification class]];
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] registerRongCloudMessageType:[RCChatRoomLiveCommand class]];
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] registerRongCloudMessageType:[RCChatRoomNotiAllMessage class]];
    [[RCIMClient sharedRCIMClient] setLogLevel:RC_Log_Level_Verbose];
    RCCRListCollectionViewController *viewController = [[RCCRListCollectionViewController alloc] init];
    
    // 初始化 UINavigationController。
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:viewController];
    
    // 初始化 rootViewController。
    self.window.rootViewController = nav;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    //AutoTest
    return YES;
}
- (void)redirectNSlogToDocumentFolder {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"MMddHHmmss"];
    NSString *formattedDate = [dateformatter stringFromDate:currentDate];
    
    NSString *fileName = [NSString stringWithFormat:@"rc%@.log", formattedDate];
    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    
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
