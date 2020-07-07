//
//  RCCRManager.m
//  ChatRoom
//
//  Created by RongCloud on 2018/5/10.
//  Copyright © 2018年 rongcloud. All rights reserved.
//

#import "RCCRManager.h"

@interface RCCRManager ()

@property (nonatomic, copy) NSArray *userArray;

@property (nonatomic, copy) NSArray *anchorArray;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation RCCRManager

+ (instancetype)sharedRCCRManager {
    static RCCRManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[RCCRManager alloc] init];
            manager.defaultToken = @"BqN79e02NNk/plp8/HADDxwKgg3t8XcRTAEaTo7s8y/MqaMKraaCRG41yMkKb3ylCjmfdm0bhh2roFkMNU0fAA==";
            manager.defaultUserId = @"wulei";
            manager.defaultUserName = @"武磊";
            NSString *usersJsonPath = [[NSBundle mainBundle] pathForResource:@"users" ofType:@"json"];
            NSData *usersData = [NSData dataWithContentsOfFile:usersJsonPath];
            //将JSON数据转为NSDictionary
            NSDictionary *usersDictArray = [NSJSONSerialization JSONObjectWithData:usersData options:NSJSONReadingMutableContainers error:nil];
            manager.userArray = usersDictArray[@"users"];
            
            NSString *anchorsJsonPath = [[NSBundle mainBundle] pathForResource:@"anchors" ofType:@"json"];
            NSData *anchorsData = [NSData dataWithContentsOfFile:anchorsJsonPath];
            //将JSON数据转为NSDictionary
            NSDictionary *anchorsDictArray = [NSJSONSerialization JSONObjectWithData:anchorsData options:NSJSONReadingMutableContainers error:nil];
            manager.anchorArray = anchorsDictArray[@"anchors"];
            manager.isBan = NO;
        }
    });
    return manager;
}

- (RCUserInfo *)getRandomUserInfo {
    int num = (arc4random() % 50) + 1;
    RCUserInfo *userInfo = [[RCUserInfo alloc] init];
    userInfo = [self getUserInfoWithNumber:num];
    return userInfo;
}

- (RCUserInfo *)getUserInfoWithNumber:(int)number {
    RCUserInfo *userInfo = [[RCUserInfo alloc] init];
    userInfo.portraitUri = [NSString stringWithFormat:@"%d",number%10 + 1];
    return userInfo;
}
    
- (RCUserInfo *)getUserInfo:(NSString *)userId {
    NSString *numStr = nil;
    RCUserInfo *userInfo = [[RCUserInfo alloc] init];
    if ([userId hasPrefix:@"number"]) {
        numStr = [userId stringByReplacingOccurrencesOfString:@"number" withString:@""];
        NSInteger selectNum = [numStr integerValue];
        NSDictionary *userDic = self.userArray[selectNum-1];
        userInfo.name = userDic[@"name"];
        userInfo.userId = userId;
        userInfo.portraitUri = [NSString stringWithFormat:@"tourists%ld",(selectNum)%10];
    }
    if ([userId hasPrefix:@"anchor"]) {
        numStr = [userId stringByReplacingOccurrencesOfString:@"anchor" withString:@""];
        NSInteger selectNum = [numStr integerValue];
        NSDictionary *anchorDic = self.anchorArray[selectNum-1];
        userInfo.name = anchorDic[@"name"];
        userInfo.userId = userId;
        userInfo.portraitUri = [NSString stringWithFormat:@"tourists%ld",(selectNum)%10];
    }
    
    
    
//    userInfo.userId = userId;
//    for (int i = 0; i<self.userArray.count; i++) {
//        NSDictionary *userDic = self.userArray[i];
//        NSString *arrUserId = userDic[@"id"];
//        if ([userId isEqualToString:arrUserId]) {
//            userInfo.name = userDic[@"name"];
//            userInfo.portraitUri = [NSString stringWithFormat:@"tourists%d",(i+1)%10];
//            break;
//        }
//    }
    if ([userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        userInfo = [RCIMClient sharedRCIMClient].currentUserInfo;
    }
    return userInfo;
}

- (BOOL)setUserBan:(int)time {
    BOOL setSuccess = YES;
    [RCCRManager sharedRCCRManager].isBan = YES;
    NSInteger duration = time * 60;
    if (@available(iOS 10.0, *)) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:duration repeats:NO block:^(NSTimer * _Nonnull timer) {
            [self setBanWithTimer];
        }];
    } else {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(setBanWithTimer) userInfo:nil repeats:NO];
    }
    return setSuccess;
}

- (void)setBanWithTimer {
    [RCCRManager sharedRCCRManager].isBan = NO;
    [self.timer invalidate];
}

- (BOOL)setUserUnban {
    BOOL setSuccess = YES;
    [RCCRManager sharedRCCRManager].isBan = NO;
    return setSuccess;
}

@end
