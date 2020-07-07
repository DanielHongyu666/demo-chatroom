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
// 规定画布大小为 640x360
#define KWidth 360
#define kHeight 640
@interface RCCRLiveModuleManager()<RCRTCRoomEventDelegate>

/**
 room
 */
@property(nonatomic , strong)RCRTCRoom *room;

/**
 layout model
 */
@property(nonatomic , strong)RCCRLiveLayoutModel *layoutModel;


/**
 live info
 */
@property(nonatomic , strong)RCRTCLiveInfo *liveInfo;


@end
@implementation RCCRLiveModuleManager
- (void)setMixStreamConfig:(RCCRLiveLayoutModel *)model{
    if ([self.chatVC isOwer]) {
        if (model == nil) {
            model = [[RCCRLiveLayoutModel alloc] initWithType:RCCRLiveLayoutTypeSuspension];
            model.suspensionCrop = NO;
        }
        self.layoutModel = model;
        if (self.room) {
            NSArray *users = self.room.remoteUsers;
            NSLog(@"current user count : %ld",users.count);
            RCRTCMixConfig *streamConfig = [self setOutputConfig:model];
            [self.liveInfo setMixStreamConfig:streamConfig completion:^(BOOL isSuccess, RCRTCCode code) {
                NSLog(@"setconfig code:%@",@(code));
            }];
           
 
        } else {
            NSLog(@"no users");
        }
    }
}
- (void)addCdn:(NSString *)addCdn completion:(void (^)(BOOL, RCRTCCode, NSArray *))completion{
    [self.liveInfo addPublishStreamUrl:addCdn completion:completion];
}
- (void)removeCdn:(NSString *)cdn completion:(void (^)(BOOL, RCRTCCode, NSArray *))completion{
    [self.liveInfo removePublishStreamUrl:cdn completion:completion];
}
- (RCRTCMixConfig *)setOutputConfig:(RCCRLiveLayoutModel *)model{
    RCRTCMixConfig *streamConfig = [[RCRTCMixConfig alloc] init];
    streamConfig.layoutMode = (int)model.layoutType ;
    // 默认画布大小
    streamConfig.mediaConfig.videoConfig.videoLayout.width = KWidth;
    streamConfig.mediaConfig.videoConfig.videoLayout.height = kHeight;
    streamConfig.mediaConfig.videoConfig.videoLayout.fps = 30;
    //    streamConfig.mediaConfig.audioConfig.bitrate = 300;
    //    streamConfig.mediaConfig.videoConfig.videoLayout.bitrate = 500;
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
    
    // 以下为自定义布局
    // 默认按照六个人靠右布局
    CGFloat height = model.height;
    CGFloat width = model.width;
    CGFloat x = model.x;
    CGFloat top = 0;
    
    NSArray *arr = self.room.localUser.localStreams;
    int i = 0;
    NSMutableArray *localArr = [NSMutableArray array];
    for (int j = 0 ; j < arr.count ; j ++) {
        RCRTCOutputStream *outputStream = arr[j];
        // 此处可以根据tag选择是否放上去，或者怎么放，因为是自定义视频，tag自己知道
        if (outputStream.mediaType == RTCMediaTypeVideo || [outputStream.tag isEqualToString:@"RongRTCFileVideo"]) {
            RCRTCCustomLayout *inputConfig = [[RCRTCCustomLayout alloc] init];
            inputConfig.videoStream = outputStream;
          
            [localArr addObject:inputConfig];
            
            // 非自定义布局时候生效。
            streamConfig.hostVideoStream = outputStream;
        }
    }
    if (model.layoutType == RCCRLiveLayoutTypeCustom) {
        for (; i < localArr.count; i ++ ) {
            RCRTCCustomLayout *inputConfig = localArr[i];
            if (i ==0 ) {
                inputConfig.x = 0;
                inputConfig.y = 0;
                inputConfig.width = KWidth;
                inputConfig.height = kHeight;
            } else {
                inputConfig.x = x;
                inputConfig.y = ((i - 1) * height);
                inputConfig.width = width;
                inputConfig.height = height;
                
            }
            top = i == 0 ? 0 : inputConfig.y + inputConfig.height;
            [streamConfig.customLayouts addObject:inputConfig];
        }
        for (; i < users.count + localArr.count; i ++ ) {
            RCRTCRemoteUser *user = users[i - localArr.count];
            int j = 0 ;
            for (RCRTCInputStream *inputStream in user.remoteStreams) {
                if (inputStream.mediaType == RTCMediaTypeVideo) {
                    RCRTCCustomLayout *inputConfig = [[RCRTCCustomLayout alloc] init];
                    inputConfig.videoStream = inputStream;
                    inputConfig.x = x;
                    inputConfig.y = top + ((i - localArr.count + j) * height);
                    inputConfig.width = width;
                    inputConfig.height = height;
                    [streamConfig.customLayouts addObject:inputConfig];
                    j ++;
                }
            }
            
        }
    }
    
    return streamConfig;
}
- (void)startCapture{
    [[RCRTCEngine sharedInstance].defaultVideoStream startCapture];
}
- (void)joinRoom:(NSString *)roomId completion:(void (^)(BOOL isSuccess ,NSInteger code, RCRTCRoom * _Nullable room))completion{
    RCRTCVideoStreamConfig *videoConfig = [[RCRTCVideoStreamConfig alloc] init];
    
    videoConfig.videoSizePreset = RCRTCVideoSizePreset640x360;
    videoConfig.videoFps = 24;
    videoConfig.minBitrate = 120*1.5;
    videoConfig.maxBitrate = 800*1.5;
    [[RCRTCEngine sharedInstance].defaultVideoStream setEnableTinyStream:YES];
    [[RCRTCEngine sharedInstance].defaultVideoStream setVideoConfig:videoConfig];
    [[RCRTCEngine sharedInstance] useSpeaker:YES] ;
    RCRTCRoomConfig *config = [[RCRTCRoomConfig alloc] init];
    config.roomType= RCRTCRoomTypeLive;
    [[RCIMClient sharedRCIMClient] setLogLevel:RC_Log_Level_Verbose];
    [[RCRTCEngine sharedInstance] joinRoom:roomId config:config completion:^(RCRTCRoom * _Nullable room, RCRTCCode code) {
        self.room = room;
        self.room.delegate = self;
        if (code == RCRTCCodeSuccess) {
            if (completion) {
                completion(YES ,0, room);
            }
        } else {
            RCLogE(@"join room error : %@",@(code));
            completion(NO ,code, nil);
        }
    }];
}
- (void)joinLive:(NSString *)liveUrl completion:(void (^)(RCRTCCode desc, RCRTCInputStream * _Nullable inputStream))completion{
    [[RCIMClient sharedRCIMClient] setLogLevel:RC_Log_Level_Verbose];
    [[RCRTCEngine sharedInstance] subscribeLiveStream:liveUrl liveType:RCRTCLiveTypeAudioVideo completion:^(RCRTCCode desc, RCRTCInputStream * _Nullable inputStream) {
        if (completion) {
            completion(desc,inputStream);
        }
    }];
    
}
- (void)quitLive:(void (^)(BOOL isSuccess, RCRTCCode code))completion{
    [[RCRTCEngine sharedInstance] unsubscribeLiveStream:nil completion:^(BOOL isSuccess, RCRTCCode code) {
        if (completion) {
            completion(isSuccess,code);
        }
    }];
    
}
- (void)publishDefaultStreams:(void (^)(BOOL isSuccess,RCRTCCode desc , RCRTCLiveInfo * _Nullable liveHostModel))completion{
    [self.room.localUser publishDefaultLiveStream:^(BOOL isSuccess, RCRTCCode desc, RCRTCLiveInfo * _Nullable liveInfo) {
        self.liveInfo = liveInfo;
        if (self.chatVC.isOwer) {
            [self setMixStreamConfig:self.layoutModel];
        }
        
        RCLogI(@"publish streams : %@",@(desc));
        if (completion) {
            completion(isSuccess,desc,liveInfo);
        }
    } ];
}
- (void)publishAVStream:(RCRTCOutputStream *)stream completiom:(void (^)(BOOL isSuccess,RCRTCCode desc ))completion{
    [self.room.localUser publishLiveStream:stream completion:^(BOOL isSuccess, RCRTCCode desc, RCRTCLiveInfo * _Nullable liveInfo) {
        if (self.chatVC.isOwer) {
            [self setMixStreamConfig:self.layoutModel];
        }
        RCLogI(@"publish av stream : %@",@(desc));
        if (completion) {
            completion(isSuccess,desc);
        }
    }];
    
}
- (void)unpublishAVStream:(RCRTCOutputStream *)stream completiom:(void (^)(BOOL isSuccess,RCRTCCode desc ))completion{
    [self.room.localUser unpublishStream:stream completion:^(BOOL isSuccess, RCRTCCode desc) {
        if (self.chatVC.isOwer) {
            [self setMixStreamConfig:self.layoutModel];
        }
        RCLogI(@"unpublish av stream : %@",@(desc));
        if (completion) {
            completion(isSuccess,desc);
        }
    }];
}
- (void)subscribeStreams:(NSArray *)streams completion:(void (^)(BOOL isSuccess,RCRTCCode desc))completion{
    if (streams.count <= 0 ) {
        if (completion) {
            completion(YES,0);
        }
        return;
    }
    [self.room.localUser subscribeStream:streams tinyStreams:nil completion:^(BOOL isSuccess, RCRTCCode desc) {
       if (completion) {
            completion(isSuccess,desc);
        }
    }];

}
-(void)quitRoom:(NSString *)roomId completion:(void (^)(BOOL isSuccess))completion{
    [[RCRTCEngine sharedInstance] leaveRoom:roomId completion:^(BOOL isSuccess, RCRTCCode code) {
        if (completion) {
            completion(isSuccess);
        }
    }];
}

-(void)didPublishStreams:(NSArray<RCRTCInputStream *> *)streams{
    [self setMixStreamConfig:self.layoutModel  ];
    if (self.delegate) {
        [self.delegate didPublishStreams:streams];
    }
}
- (void)didJoinUser:(RCRTCRemoteUser *)user{
    if (self.delegate) {
        [self.delegate didJoinUser:user];
    }
}
-(void)didLeaveUser:(RCRTCRemoteUser *)user{
    if (self.delegate) {
        [self.delegate didLeaveUser:user];
    }
    if (self.room.remoteUsers.count <= 0) {
        [self.delegate remoteUsersIsNull];
    }
}
-(void)didUnpublishStreams:(NSArray<RCRTCInputStream *> *)streams{
    if (self.delegate) {
        [self.delegate didUnpublishStreams:streams];
    }
}
-(void)didReportFirstKeyframe:(RCRTCInputStream *)stream{
    NSLog(@"live receive first key frame : %@",stream.streamId);
}
@end
