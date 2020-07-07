//
//  RCCRUtilities.m
//  ChatRoom
//
//  Created by 孙承秀 on 2018/5/10.
//  Copyright © 2018年 RongCloud. All rights reserved.
//
#import <RongRTCLib/RongRTCLib.h>
#import "RCCRUtilities.h"
#import <CommonCrypto/CommonDigest.h>
@interface RCCRTimerProxy : NSObject
- (instancetype)initWithInterval:(NSTimeInterval)interval
                         repeats:(BOOL)repeats
                    complement:(void (^)(void))complement;
- (void)invalidate;
@end
@implementation RCCRTimerProxy{
  NSTimer *_timer;
  void (^_complement)(void);
}


- (instancetype)initWithInterval:(NSTimeInterval)interval
                         repeats:(BOOL)repeats
                    complement:(void (^)(void))complement {
  if (self = [super init]) {
    _complement = complement;
    _timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                              target:self
                                            selector:@selector(timerDidFire:)
                                            userInfo:nil
                                             repeats:repeats];
  }
  return self;
}

- (void)invalidate {
  [_timer invalidate];
}

- (void)timerDidFire:(NSTimer *)timer {
  _complement();
}

@end

@interface RCCRUtilities(){
    RCCRTimerProxy *_timer;
}
/**
 是否封禁
 */
@property(nonatomic , assign)BOOL locked;;

/**
 roomid
 */
@property(nonatomic , copy)NSString *roomId;
@end
@implementation RCCRUtilities
+(instancetype)instance{
    static dispatch_once_t onceToken;
    static RCCRUtilities *ut = nil;
    dispatch_once(&onceToken, ^{
        ut = [[RCCRUtilities alloc] init];
    });
    return ut;
}
-(void)blockRoom:(NSString *)roomId duration:(int)duration{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _locked = YES;
    _roomId = roomId;
    __weak typeof(self)weakSelf = self;
    _timer = [[RCCRTimerProxy alloc] initWithInterval:duration*60 repeats:NO complement:^{
        weakSelf.locked= NO;
        weakSelf.roomId = nil;
    }];
}
-(BOOL)isLockedRoom:(NSString *)roomId{
    if ([roomId isEqualToString:self.roomId] && self.locked) {
        return YES;
    } else {
        return NO;
    }
}
+ (NSString *)getDemoVersion{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return version;
}
+(NSString *)getRTCLibSDKVersion{
    return [[RCRTCEngine sharedInstance] getRTCLibVersion];
}
+ (NSInteger)compareVersion:(NSString *)version1 toVersion:(NSString *)version2
{
    NSArray *list1 = [version1 componentsSeparatedByString:@"."];
    NSArray *list2 = [version2 componentsSeparatedByString:@"."];
    for (int i = 0; i < list1.count || i < list2.count; i++)
    {
        NSInteger a = 0, b = 0;
        if (i < list1.count) {
            a = [list1[i] integerValue];
        }
        if (i < list2.count) {
            b = [list2[i] integerValue];
        }
        if (a > b) {
            return 1;//version1大于version2
        } else if (a < b) {
            return -1;//version1小于version2
        }
    }
    return 0;//version1等于version2
    
}
//可以使用一下语句判断是否是刘海手机：
+ (BOOL)isPhoneX {
   CGFloat height = UIApplication.sharedApplication.statusBarFrame.size.height;
   if (height >= 44.0) {
       return YES;
   }
    return NO;
}
+ (NSString *)md5:(NSString *)input {
    //传入参数,转化成char
    const char * str = [input UTF8String];
    //开辟一个16字节（128位：md5加密出来就是128位/bit）的空间（一个字节=8字位=8个二进制数）
    unsigned char md[CC_MD5_DIGEST_LENGTH];
    /*
     extern unsigned char * CC_MD5(const void *data, CC_LONG len, unsigned char *md)官方封装好的加密方法
     把str字符串转换成了32位的16进制数列（这个过程不可逆转） 存储到了md这个空间中
     */
    CC_MD5(str, (int)strlen(str), md);
    //创建一个可变字符串收集结果
    NSMutableString * ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        /**
         X 表示以十六进制形式输入/输出
         02 表示不足两位，前面补0输出；出过两位不影响
         printf("%02X", 0x123); //打印出：123
         printf("%02X", 0x1); //打印出：01
         */
        [ret appendFormat:@"%02X",md[i]];
    }
    //返回一个长度为32的字符串
    return ret;
}
@end
