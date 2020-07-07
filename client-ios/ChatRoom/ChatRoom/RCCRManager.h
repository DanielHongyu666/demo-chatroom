//
//  RCCRManager.h
//  ChatRoom
//
//  Created by RongCloud on 2018/5/10.
//  Copyright © 2018年 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>

@interface RCCRManager : NSObject

+ (instancetype)sharedRCCRManager;

@property (nonatomic, copy) NSString *defaultToken;

@property (nonatomic, copy) NSString *defaultUserId;

@property (nonatomic, copy) NSString *defaultUserName;

@property (nonatomic, copy) NSString *portraitUri;

@property (nonatomic, assign) BOOL isBan;

- (RCUserInfo *)getRandomUserInfo;

- (RCUserInfo *)getUserInfo:(NSString *)userId;

- (BOOL)setUserBan:(int)time;

- (BOOL)setUserUnban;

@end
