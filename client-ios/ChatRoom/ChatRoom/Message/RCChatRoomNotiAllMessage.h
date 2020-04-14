//
//  RCChatRoomNotiAllMessage.h
//  ChatRoom
//
//  Created by 孙承秀 on 2019/9/10.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>
NS_ASSUME_NONNULL_BEGIN

@interface RCChatRoomNotiAllMessage : RCMessageContent

/**
 userInfos
 */
@property(nonatomic , copy)NSMutableArray *userInfos;

/**
 extra
 */
@property(nonatomic , copy)NSString *extra;
@end

NS_ASSUME_NONNULL_END
