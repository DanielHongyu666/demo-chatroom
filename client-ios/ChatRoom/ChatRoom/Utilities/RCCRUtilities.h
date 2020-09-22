//
//  RCCRUtilities.h
//  ChatRoom
//
//  Created by 孙承秀 on 2018/5/10.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ISX [UIScreen mainScreen].bounds.size.height == 812
typedef NS_ENUM(NSInteger , RCCRExchangeType) {
    // 只拉音频
    RCCRExchangeTypeAudio = 0,
    // 只拉视频
    RCCRExchangeTypeVideo = 1,
    // 拉大流
    RCCRExchangeTypeAudioVideo = 2,
    // 拉视频小流
    RCCRExchangeTypeVideo_tiny = 3,
    // 音视频小流
    RCCRExchangeTypeAudioVideo_tiny = 4,
};

@interface RCCRUtilities : NSObject
+ (instancetype)instance;
- (void)blockRoom:(NSString *)roomId duration:(int)duration;
- (BOOL)isLockedRoom:(NSString *)roomId;
+ (NSInteger)compareVersion:(NSString *)version1 toVersion:(NSString *)version2;
+ (NSString *)getDemoVersion;
+ (NSString *)getRTCLibSDKVersion;
+ (NSString *)getdeviceName;
+ (BOOL)isPhoneX;
+ (NSString *)md5:(NSString *)input ;
@end
