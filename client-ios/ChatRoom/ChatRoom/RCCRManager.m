//
//  RCCRManager.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/10.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "RCCRManager.h"

@interface RCCRManager ()

@property (nonatomic, copy) NSArray *userArray;

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
            NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"users" ofType:@"json"];
            NSData *data = [NSData dataWithContentsOfFile:jsonPath];
            //将JSON数据转为NSDictionary
            NSDictionary *dictArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            manager.userArray = dictArray[@"users"];
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
    NSDictionary *userDic = self.userArray[number - 1];
    userInfo.userId = userDic[@"id"];
    userInfo.name = userDic[@"name"];
    userInfo.portraitUri = [NSString stringWithFormat:@"tourists%d",number%10];
    self.defaultToken = userDic[@"token"];
    return userInfo;
}
    
- (RCUserInfo *)getUserInfo:(NSString *)userId {
    
    NSString *numStr = [userId stringByReplacingOccurrencesOfString:@"number" withString:@""];
    NSInteger selectNum = [numStr integerValue];
    NSDictionary *userDic = self.userArray[selectNum-1];
    RCUserInfo *userInfo = [[RCUserInfo alloc] init];
    userInfo.name = userDic[@"name"];
    userInfo.userId = userId;
    userInfo.portraitUri = [NSString stringWithFormat:@"tourists%ld",(selectNum)%10];
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
    return userInfo;
}

@end
