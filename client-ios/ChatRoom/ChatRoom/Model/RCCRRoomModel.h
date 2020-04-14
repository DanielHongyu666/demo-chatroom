//
//  RCCRRoomModel.h
//  ChatRoom
//
//  Created by 孙承秀 on 2019/9/9.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCCRRoomModel : NSObject

/**
 封面下标
 */
@property(nonatomic , assign)NSInteger coverIndex;

/**
 直播观看地址
 */
@property(nonatomic , copy)NSString *liveUrl;

/**
 直播者 ID
 */
@property(nonatomic , copy)NSString *pubUserId;

/**
 房间 ID
 */
@property(nonatomic , copy)NSString *roomId;

/**
 room name
 */
@property(nonatomic , copy)NSString *roomName;

/**
 时间戳
 */
@property(nonatomic , copy)NSString *date;

@end

NS_ASSUME_NONNULL_END
