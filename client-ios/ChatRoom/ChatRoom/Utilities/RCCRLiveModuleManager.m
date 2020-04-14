//
//  RCCRLiveModuleManager.m
//  ChatRoom
//
//  Created by 孙承秀 on 2019/8/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCCRLiveModuleManager.h"
#import "RCCRLiveHttpManager.h"
#import "RCCRLiveLayoutModel.h"
// 规定画布大小为 640x480
#define KWidth 480
#define kHeight 640
@interface RCCRLiveModuleManager()<RongRTCRoomDelegate>

/**
 room
 */
@property(nonatomic , strong)RongRTCRoom *room;

/**
 layout model
 */
@property(nonatomic , strong)RCCRLiveLayoutModel *layoutModel;


/**
 live info
 */
@property(nonatomic , strong)RongRTCLiveInfo *liveInfo;


@end
@implementation RCCRLiveModuleManager
- (void)setMixStreamConfig:(RCCRLiveLayoutModel *)model{
    if ([self.chatVC isOwer]) {
        if (model == nil) {
            model = [[RCCRLiveLayoutModel alloc] initWithType:RCCRLiveLayoutTypeSuspension];
            model.suspensionCrop = YES;
        }
        self.layoutModel = model;
        if (self.room) {
            NSArray *users = self.room.remoteUsers;
            NSLog(@"current user count : %ld",users.count);
            RongRTCMixConfig *streamConfig = [self setOutputConfig:model];
            [self.liveInfo setMixStreamConfig:streamConfig completion:^(BOOL isSuccess, RongRTCCode code) {
                NSLog(@"setconfig code:%@",@(code));
            }];
        } else {
            NSLog(@"no users");
        }
    }
    
    
}
- (RongRTCMixConfig *)setOutputConfig:(RCCRLiveLayoutModel *)model{
    RongRTCMixConfig *streamConfig = [[RongRTCMixConfig alloc] init];
    streamConfig.layoutMode = (int)model.layoutType ;
    // 默认画布大小
    streamConfig.mediaConfig.videoConfig.videoLayout.width = KWidth;
    streamConfig.mediaConfig.videoConfig.videoLayout.height = kHeight;
    streamConfig.mediaConfig.videoConfig.videoLayout.fps = 30;
    streamConfig.mediaConfig.audioConfig.bitrate = 300;
    streamConfig.mediaConfig.videoConfig.videoLayout.bitrate = 500;
    if (model.layoutType == RCCRLiveLayoutTypeAdaptive) {
        streamConfig.mediaConfig.videoConfig.videoExtend.renderMode = model.adaptiveCrop ? 1:2;
    }
    if (model.layoutType == RCCRLiveLayoutTypeSuspension) {
        streamConfig.mediaConfig.videoConfig.videoExtend.renderMode = model.suspensionCrop ?1:2;
    }
    if (model.layoutType == RCCRLiveLayoutTypeCustom) {
        streamConfig.mediaConfig.videoConfig.videoExtend.renderMode = model.customCrop ?1:2;
    }

    NSArray *users = self.room.remoteUsers;
    // 默认按照六个人靠右布局
    CGFloat height = model.height;
    CGFloat width = model.width;
    CGFloat x = model.x;
    CGFloat top = 0;
    RongRTCCustomLayout *inputConfig = [[RongRTCCustomLayout alloc] init];
    inputConfig.userId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
    inputConfig.x = 0;
    inputConfig.y = 0;
    inputConfig.width = 480;
    inputConfig.height = 640;
    [streamConfig.customLayouts addObject:inputConfig];
    for (int i = 0; i < users.count; i ++ ) {
        RongRTCRemoteUser *user = users[i];
        RongRTCCustomLayout *inputConfig = [[RongRTCCustomLayout alloc] init];
        inputConfig.userId = user.userId;
        inputConfig.x = x;
        inputConfig.y = top + (i * height);
        inputConfig.width = width;
        inputConfig.height = height;
        [streamConfig.customLayouts addObject:inputConfig];
    }
    return streamConfig;
}
- (void)startCapture{
   
    [[RongRTCAVCapturer sharedInstance] startCapture];
}
- (void)joinRoom:(NSString *)roomId completion:(void (^)(BOOL isSuccess ,NSInteger code, RongRTCRoom * _Nullable room))completion{
    RongRTCVideoCaptureParam *param = [[RongRTCVideoCaptureParam alloc] init];
       param.tinyStreamEnable = NO;
    param.videoSizePreset = RongRTCVideoSizePreset640x480;
    [[RongRTCAVCapturer sharedInstance] setCaptureParam:param];
    RongRTCRoomConfig *config = [[RongRTCRoomConfig alloc] init];
    config.roomType= RongRTCRoomTypeLive;
    [[RCIMClient sharedRCIMClient] setLogLevel:RC_Log_Level_Verbose];
    [[RongRTCEngine sharedEngine] joinRoom:roomId config:config completion:^(RongRTCRoom * _Nullable room, RongRTCCode code) {
        self.room = room;
        self.room.delegate = self;
        if (code == RongRTCCodeSuccess) {
            if (completion) {
                completion(YES ,0, room);
            }
        } else {
            RCLogE(@"join room error : %@",@(code));
            completion(NO ,code, nil);
        }
    }];
}
- (void)joinLive:(NSString *)liveUrl completion:(void (^)(RongRTCCode desc, RongRTCLiveAVInputStream * _Nullable inputStream))completion{
    [[RCIMClient sharedRCIMClient] setLogLevel:RC_Log_Level_Verbose];
    [[RongRTCEngine sharedEngine] subscribeLiveAVStream:liveUrl liveType:(RongRTCLiveTypeAudioVideo) handler:^(RongRTCCode desc, RongRTCLiveAVInputStream * _Nullable inputStream) {
        if (completion) {
            completion(desc,inputStream);
        }
    }];

}
- (void)quitLive:(void (^)(BOOL isSuccess, RongRTCCode code))completion{
    [[RongRTCEngine sharedEngine] unsubscribeLiveAVStream:nil completion:^(BOOL isSuccess, RongRTCCode code) {
        if (completion) {
            completion(isSuccess,code);
        }
    }];

    
}
- (void)publishStreams:(void (^)(BOOL isSuccess,RongRTCCode desc , RongRTCLiveInfo * _Nullable liveHostModel))completion{
    [self.room publishDefaultLiveAVStream:^(BOOL isSuccess, RongRTCCode desc, RongRTCLiveInfo * _Nullable liveInfo) {
        self.liveInfo = liveInfo;
        if (self.chatVC.isOwer) {
            [self setMixStreamConfig:self.layoutModel];
        }
        
        RCLogI(@"publish streams : %@",@(desc));
        if (completion) {
            completion(isSuccess,desc,liveInfo);
        }
    }];
}
- (void)subscribeStreams:(NSArray *)streams completion:(void (^)(BOOL isSuccess,RongRTCCode desc))completion{
    if (streams.count <= 0 ) {
        if (completion) {
            completion(YES,0);
        }
        return;
    }
    [self.room subscribeAVStream:nil tinyStreams:streams completion:^(BOOL isSuccess, RongRTCCode desc) {
        if (completion) {
            completion(isSuccess,desc);
        }
    }];
}
-(void)quitRoom:(NSString *)roomId completion:(void (^)(BOOL isSuccess))completion{
    [[RongRTCEngine sharedEngine] leaveRoom:roomId completion:^(BOOL isSuccess, RongRTCCode code) {
        if (completion) {
            completion(isSuccess);
        }
    }];
}

-(void)didPublishStreams:(NSArray<RongRTCAVInputStream *> *)streams{
    [self setMixStreamConfig:self.layoutModel  ];
    if (self.delegate) {
        [self.delegate didPublishStreams:streams];
    }
}
- (void)didJoinUser:(RongRTCRemoteUser *)user{
    if (self.delegate) {
        [self.delegate didJoinUser:user];
    }
}
-(void)didLeaveUser:(RongRTCRemoteUser *)user{
    if (self.delegate) {
        [self.delegate didLeaveUser:user];
    }
    if (self.room.remoteUsers.count <= 0) {
        [self.delegate remoteUsersIsNull];
    }
}
-(void)didUnpublishStreams:(NSArray<RongRTCAVInputStream *> *)streams{
    if (self.delegate) {
        [self.delegate didUnpublishStreams:streams];
    }
}
-(void)didReportFirstKeyframe:(RongRTCAVInputStream *)stream{
    NSLog(@"live receive first key frame : %@",stream.streamId);
}
@end
