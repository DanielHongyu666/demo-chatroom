//
//  RCCRLiveChatRoomViewController.h
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/9.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMLib/RongIMLib.h>
#import "RCCRLiveModel.h"

@interface RCCRLiveChatRoomViewController : UIViewController

/**
 当前会话的会话类型
 */
@property(nonatomic, assign) RCConversationType conversationType;

/**
 目标会话ID
 */
@property(nonatomic, copy) NSString *targetId;

/**
 数据模型
 */
@property(nonatomic, strong) RCCRLiveModel *model;

/**
 设置进入聊天室需要获取的历史消息数量（仅在当前会话为聊天室时生效）
 
 @discussion 此属性需要在viewDidLoad之前进行设置。
 -1表示不获取任何历史消息，0表示不特殊设置而使用SDK默认的设置（默认为获取10条），0<messageCount<=50为具体获取的消息数量,最大值为50。
 */
@property(nonatomic, assign) int defaultHistoryMessageCountOfChatRoom;

@end
