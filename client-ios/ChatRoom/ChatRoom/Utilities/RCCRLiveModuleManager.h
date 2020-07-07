//
//  RCCRLiveModuleManager.h
//  ChatRoom
//
//  Created by 孙承秀 on 2019/8/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongRTCLib/RongRTCLib.h>
#import "RCCRLiveLayoutModel.h"
#import "RCCRLiveModuleManager.h"
#import "RCCRLiveChatRoomViewController.h"
NS_ASSUME_NONNULL_BEGIN
@protocol RCCRLiveModuleDelegate;
@interface RCCRLiveModuleManager : NSObject

/**
 delegate
 */
@property(nonatomic , weak)id <RCCRLiveModuleDelegate> delegate;

/**
 vc
 */
@property(nonatomic , weak)RCCRLiveChatRoomViewController *chatVC;


/// 开启硬件设备
- (void)startCapture;

/// 加入房间
/// @param roomId 房间号
/// @param completion 回调
- (void)joinRoom:(NSString *)roomId completion:(void (^)(BOOL isSuccess,NSInteger code , RCRTCRoom * _Nullable room))completion;

/// 退出房间
/// @param roomId 房间号
/// @param completion 回调
- (void)quitRoom:(NSString *)roomId completion:(void (^)(BOOL isSuccess))completion;

/// 发布默认资源
/// @param completion 回调
- (void)publishDefaultStreams:(void (^)(BOOL isSuccess ,RCRTCCode desc, RCRTCLiveInfo * _Nullable liveHostModel))completion;

/// 发布资源
/// @param completion 回调
- (void)publishAVStream:(RCRTCOutputStream *)stream completiom:(void (^)(BOOL isSuccess,RCRTCCode desc ))completion;

/// 取消发布资源
/// @param completion 回调
- (void)unpublishAVStream:(RCRTCOutputStream *)stream completiom:(void (^)(BOOL isSuccess,RCRTCCode desc ))completion;
/// 订阅资源
/// @param streams 要订阅的资源
/// @param completion 回调
- (void)subscribeStreams:(NSArray *)streams completion:(void (^)(BOOL isSuccess,RCRTCCode desc))completion;

/// 观众订阅主播的资源，观看直播
/// @param liveUrl 主播直播的 url
/// @param completion 回调
- (void)joinLive:(NSString *)liveUrl completion:(void (^)(RCRTCCode desc, RCRTCInputStream * _Nullable inputStream))completion;

/// 观众退出观看
/// @param completion 回调
- (void)quitLive:(void (^)(BOOL isSuccess, RCRTCCode code))completion;

/// 设置合流布局
/// @param model 布局模型
- (void)setMixStreamConfig:(RCCRLiveLayoutModel *)model;

/// 配置 cdn 地址
/// @param addCdn cdn 地址
/// @param completion cdn 回调
- (void)addCdn:(NSString *)addCdn completion:(void (^)(BOOL, RCRTCCode, NSArray *))completion;

/// 移除 cdn
/// @param cdn cdn地址
/// @param completion 回调
- (void)removeCdn:(NSString *)cdn completion:(void (^)(BOOL, RCRTCCode, NSArray *))completion;
@end
@protocol RCCRLiveModuleDelegate <NSObject>

/// 有人发布资源的代理
/// @param streams 发布的资源
-(void)didPublishStreams:(NSArray<RCRTCInputStream *> *)streams;

/// 有人离开的回调
/// @param user 离开的 user
-(void)didLeaveUser:(RCRTCRemoteUser *)user;

/// 有人加入的代理
/// @param user 加入的 user
- (void)didJoinUser:(RCRTCRemoteUser *)user;

/// 有人取消发布资源的代理
/// @param streams 取消发布的资源
-(void)didUnpublishStreams:(NSArray<RCRTCInputStream *> *)streams;

/// 当远端人为空的代理
- (void)remoteUsersIsNull;


@end
NS_ASSUME_NONNULL_END
