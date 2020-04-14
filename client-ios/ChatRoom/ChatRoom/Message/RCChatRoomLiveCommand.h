//
//  RCChatRoomLIveCommand.h
//  ChatRoom
//
//  Created by 孙承秀 on 2019/9/6.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger , RCCRLiveCommandType) {
    RCCRLiveCommandTypeInvite = 1 ,
    RCCRLiveCommandTypeAccept,
    RCCRLiveCommandTypeReject
};
@interface RCChatRoomLiveCommand : RCMessageContent

/**
 消息命令类型
 */
@property(nonatomic , assign)RCCRLiveCommandType commandType;

/**
 roomId
 */
@property(nonatomic , copy)NSString *roomId;


/**
 extra
 */
@property(nonatomic , copy)NSString *extra;

@end

NS_ASSUME_NONNULL_END
