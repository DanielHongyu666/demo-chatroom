//
//  AppDelegate.h
//  ChatRoom
//
//  Created by RongCloud on 2018/5/9.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#error 需要将下面的 appkey 和 appserver 替换为自己的值，然后将这一行注释去掉就可以，要不然编译不过，替换完一定要删除这一行！
#define RCIMAPPKey @"替换为自己的 APPKEY"
#define APPSERVER @"替换为自己的 APPServer"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

