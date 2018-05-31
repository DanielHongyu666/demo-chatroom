//
//  RCCRManager.h
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/10.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>

@interface RCCRManager : NSObject

+ (instancetype)sharedRCCRManager;

@property (nonatomic, copy) NSString *defaultToken;

@property (nonatomic, copy) NSString *defaultUserId;

@property (nonatomic, copy) NSString *defaultUserName;

@property (nonatomic, copy) NSString *portraitUri;

- (RCUserInfo *)getRandomUserInfo;

- (RCUserInfo *)getUserInfo:(NSString *)userId;

@end
