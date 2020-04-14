//
//  RCChatRoomNotiAllMessage.m
//  ChatRoom
//
//  Created by 孙承秀 on 2019/9/10.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCChatRoomNotiAllMessage.h"
#define EXTRA @"extra"
#define USERINFOS @"userInfos"
@implementation RCChatRoomNotiAllMessage
- (NSData *)encode {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    
    if (self.extra) {
        [dataDict setObject:self.extra forKey:EXTRA];
    } else {
        [dataDict setObject:@"" forKey:EXTRA];
    }
    // 所有主播包括自己的用户信息
    if (self.userInfos) {
        NSMutableArray *arr = [NSMutableArray array];
        for (RCUserInfo *userInfo in self.userInfos) {
            NSDictionary *dic = [self encodeUserInfo:userInfo];
            [arr addObject:dic];
        }
        NSDictionary *selfuserInfo = [self encodeUserInfo:self.senderUserInfo];
        if (![arr containsObject:selfuserInfo]) {
            [arr addObject:selfuserInfo];
        }
        [dataDict setObject:arr forKey:USERINFOS];
    } else {
        [dataDict setObject:@"" forKey:USERINFOS];
    }
    if (self.senderUserInfo) {
        [dataDict setObject:[self encodeUserInfo:self.senderUserInfo] forKey:@"user"];
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:kNilOptions error:nil];
    return data;
}
- (NSDictionary *)encodeUserInfo:(RCUserInfo *)userInfo {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if (userInfo.name) {
        [dic setObject:userInfo.name forKeyedSubscript:@"name"];
    }
    if (userInfo.portraitUri) {
        [dic setObject:userInfo.portraitUri forKeyedSubscript:@"portrait"];
    }
    if (userInfo.userId) {
        [dic setObject:userInfo.userId forKeyedSubscript:@"id"];
    }
    return dic.copy;
}
- (RCUserInfo *)decodeSelfUserInfo:(NSDictionary *)dictionary {
    NSDictionary *userinfoDic = [[NSDictionary alloc] initWithDictionary:dictionary];
    RCUserInfo *userinfo = [RCUserInfo new];
    if (userinfoDic) {
        userinfo.userId = [userinfoDic objectForKey:@"id"];
        userinfo.name = [userinfoDic objectForKey:@"name"];
        userinfo.portraitUri = [userinfoDic objectForKey:@"portrait"];
    }
    return userinfo;
}
- (void)decodeWithData:(NSData *)data {
    if (data == nil) {
        return;
    }
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSDictionary *json = [[NSDictionary alloc] initWithDictionary:dictionary];
    if (json) {
        self.extra = [json objectForKey:EXTRA];
        NSArray *arr = [json objectForKey:USERINFOS];
        NSMutableArray *marr = [NSMutableArray array];
        for (NSDictionary *dic in arr) {
            RCUserInfo *userInfo = [self decodeSelfUserInfo:dic];
            [marr addObject:userInfo];
        }
        self.userInfos = marr.mutableCopy;
        NSDictionary *userinfoDic = dictionary[@"user"];
        [self decodeUserInfo:userinfoDic];
    }
}

+ (NSString *)getObjectName {
  return @"RC:Chatroom:SyncUserInfo";
}

- (NSArray<NSString *> *)getSearchableWords {
  return nil;
}

+ (RCMessagePersistent)persistentFlag {
  return MessagePersistent_STATUS;
}

@end
