//
//  RCCRRongCloudIMManager.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/9.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "RCCRRongCloudIMManager.h"

NSString *const RCCRKitDispatchMessageNotification = @"RCCRKitDispatchMessageNotification";

NSString *const RCCRConnectChangeNotification = @"RCCRConnectChangeNotification";

@interface RCCRRongCloudIMManager () <RCConnectionStatusChangeDelegate, RCIMClientReceiveMessageDelegate>

@property (nonatomic, copy) NSString *appKey;

@end

static RCCRRongCloudIMManager *__rongUIKit = nil;

dispatch_queue_t __RCDLive_ConversationList_refresh_queue = NULL;

@implementation RCCRRongCloudIMManager

//+ (instancetype)sharedRCCRRongCloudIMManager {
//    static RCCRRongCloudIMManager *manager = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        if (manager == nil) {
//            manager = [[RCCRRongCloudIMManager alloc] init];
//            manager.isLogin = NO;
//        }
//    });
//    return manager;
//}

+ (instancetype)sharedRCCRRongCloudIMManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (__rongUIKit == nil) {
            __rongUIKit = [[RCCRRongCloudIMManager alloc] init];
            __RCDLive_ConversationList_refresh_queue = dispatch_queue_create("com.rongcloud.refreshConversationList", NULL);
        }
    });
    return __rongUIKit;
}

- (void)initRongCloud:(NSString *)appKey{
    if ([self.appKey isEqual:appKey]) {
        NSLog(@"Warning:请不要重复调用Init！！！");
        return;
    }
    
    self.appKey = appKey;
    [[RCIMClient sharedRCIMClient] initWithAppKey:appKey];
    // listen receive message
    [[RCIMClient sharedRCIMClient] setReceiveMessageDelegate:self object:nil];
    [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:self];
}

- (void)onConnectionStatusChanged:(RCConnectionStatus)status {

    NSDictionary *user = @{ @"status" : @(status) };
    [[NSNotificationCenter defaultCenter] postNotificationName:RCCRConnectChangeNotification
                                                        object:nil
                                                      userInfo:user];
}

- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object {
    
    NSDictionary *dic_left = @{ @"left" : @(nLeft) };
    // dispatch message
    [[NSNotificationCenter defaultCenter] postNotificationName:RCCRKitDispatchMessageNotification
                                                        object:message
                                                      userInfo:dic_left];
}

- (void)registerRongCloudMessageType:(Class)messageClass {
    [[RCIMClient sharedRCIMClient] registerMessageType:messageClass];
}

- (void)connectRongCloudWithToken:(NSString *)token
                          success:(void (^)(NSString *userId))successBlock
                            error:(void (^)(RCConnectErrorCode status))errorBlock
                   tokenIncorrect:(void (^)(void))tokenIncorrectBlock {
    [[RCIMClient sharedRCIMClient] connectWithToken:token
                                            success:^(NSString *userId) {
                                                if (successBlock!=nil) {
                                                    successBlock(userId);
                                                }
                                            }
                                              error:^(RCConnectErrorCode status) {
                                                  if(errorBlock!=nil)
                                                      errorBlock(status);
                                              }
                                     tokenIncorrect:^() {
                                         tokenIncorrectBlock();
                                     }];
}

- (void)disconnectRongCloud{
    [[RCIMClient sharedRCIMClient] setReceiveMessageDelegate:nil object:nil];
    [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:nil];
    [[RCIMClient sharedRCIMClient] disconnect];
}

- (void)disconnectRongCloud:(BOOL)isReceivePush {
    [[RCIMClient sharedRCIMClient] setReceiveMessageDelegate:nil object:nil];
    [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:nil];
    [[RCIMClient sharedRCIMClient] disconnect:isReceivePush];
}

- (void)logoutRongCloud {
//    [[RCIMClient sharedRCIMClient] setReceiveMessageDelegate:nil object:nil];
//    [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:nil];
    [[RCIMClient sharedRCIMClient] logout];
}

- (RCMessage *)sendMessage:(RCConversationType)conversationType
                  targetId:(NSString *)targetId
                   content:(RCMessageContent *)content
               pushContent:(NSString *)pushContent
                  pushData:(NSString *)pushData
                   success:(void (^)(long messageId))successBlock
                     error:(void (^)(RCErrorCode nErrorCode,
                                     long messageId))errorBlock {
    RCMessage *rcMessage = [[RCIMClient sharedRCIMClient]
                            sendMessage:conversationType
                            targetId:targetId
                            content:content
                            pushContent:pushContent
                            pushData:pushData
                            success:^(long messageId) {
//                                NSDictionary *statusDic = @{@"targetId":targetId,
//                                                            @"conversationType":@(conversationType),
//                                                            @"messageId": @(messageId),
//                                                            @"sentStatus": @(SentStatus_SENT),
//                                                            @"content":content};
//                                [[NSNotificationCenter defaultCenter]
//                                 postNotificationName:RCDLiveKitSendingMessageNotification
//                                 object:nil
//                                 userInfo:statusDic];
                                NSLog(@"发送成功");
                                successBlock(messageId);
                            } error:^(RCErrorCode nErrorCode, long messageId) {
//                                NSDictionary *statusDic = @{@"targetId":targetId,
//                                                            @"conversationType":@(conversationType),
//                                                            @"messageId": @(messageId),
//                                                            @"sentStatus": @(SentStatus_FAILED),
//                                                            @"error": @(nErrorCode),
//                                                            @"content":content};
//                                [[NSNotificationCenter defaultCenter]
//                                 postNotificationName:RCDLiveKitSendingMessageNotification
//                                 object:nil
//                                 userInfo:statusDic];
                                NSLog(@"发送失败 errorcode : %ld",(long)nErrorCode);
                                errorBlock(nErrorCode,messageId);
                            }];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:RCDLiveKitSendingMessageNotification
//                                                        object:rcMessage
//                                                      userInfo:nil];
    return rcMessage;
}

- (RCConnectionStatus)getRongCloudConnectionStatus {
    return [[RCIMClient sharedRCIMClient] getConnectionStatus];
}

- (void)setCurrentUserInfo:(RCUserInfo *)currentUserInfo {
    
    [[RCIMClient sharedRCIMClient] setCurrentUserInfo:currentUserInfo];
}

- (RCUserInfo *)currentUserInfo {
    return [[RCIMClient sharedRCIMClient] currentUserInfo];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
