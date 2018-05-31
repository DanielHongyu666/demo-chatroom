//
//  RCCRLiveModel.h
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/10.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCCRLiveModel : NSObject

/**
 主播名称
 */
@property (nonatomic, copy) NSString *hostName;

/**
 主播头像
 */
@property (nonatomic, copy) NSString *hostPortrait;

/**
 观众数
 */
@property (nonatomic, assign) NSInteger audienceAmount;

/**
 粉丝数
 */
@property (nonatomic, assign) NSInteger fansAmount;

/**
 获赞数
 */
@property (nonatomic, assign) NSInteger praiseAmount;

/**
 获得礼物数
 */
@property (nonatomic, assign) NSInteger giftAmount;

/**
 关注数
 */
@property (nonatomic, assign) NSInteger attentionAmount;

@end
