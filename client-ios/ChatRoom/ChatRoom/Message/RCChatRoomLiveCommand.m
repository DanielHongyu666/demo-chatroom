//
//  RCChatRoomLiveCommand.m
//  ChatRoom
//
//  Created by 孙承秀 on 2019/9/6.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCChatRoomLiveCommand.h"
#define ROOMID @"roomId"
#define EXTRA @"extra"
#define TYPE @"cmdType"
@implementation RCChatRoomLiveCommand

- (NSData *)encode {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    
    if (self.roomId) {
        [dataDict setObject:self.roomId forKey:ROOMID];
    } else {
        [dataDict setObject:@"" forKey:ROOMID];
    }
    if (self.extra) {
        [dataDict setObject:self.extra forKey:EXTRA];
    } else {
        [dataDict setObject:@"" forKey:EXTRA];
    }
    [dataDict setObject:@(self.commandType) forKey:TYPE];
    if (self.senderUserInfo) {
        [dataDict setObject:[self encodeUserInfo:self.senderUserInfo] forKey:@"user"];
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:kNilOptions error:nil];
    return data;
}

- (void)decodeWithData:(NSData *)data {
    if (data == nil) {
        return;
    }
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSDictionary *json = [[NSDictionary alloc] initWithDictionary:dictionary];
    if (json) {
        self.roomId = [json objectForKey:ROOMID];
        self.commandType = [[json objectForKey:TYPE] integerValue];
        self.extra = [json objectForKey:@"extra"];
        NSDictionary *userinfoDic = dictionary[@"user"];
        [self decodeUserInfo:userinfoDic];
    }
}

+ (NSString *)getObjectName {
  return @"RC:Chatroom:LiveCmd";
}

- (NSArray<NSString *> *)getSearchableWords {
  return nil;
}

+ (RCMessagePersistent)persistentFlag {
  return MessagePersistent_STATUS;
}

@end
