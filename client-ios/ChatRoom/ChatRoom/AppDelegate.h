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
#define RCCDNSERVER @"替换为自己的 CndServer"

//RCNAVI 为 IM 导航地址，如果不填写使用 token 里面的；RTCMEDIASERVERURL 为自己指定 MediaServer 地址，如果不填写使用导航下发默认配置，这两项没有特殊需求请不要填写。
#define RCNAVI @""
#define RTCMEDIASERVERURL @""

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

