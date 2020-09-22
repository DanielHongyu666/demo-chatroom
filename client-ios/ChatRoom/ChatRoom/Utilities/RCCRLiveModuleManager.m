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

#define kTinyWidth 144
#define KTinyHeight 176
#define KTinyBitrate 120
#define KTinyFrame 15
@interface RCCRLiveModuleManager()<RCRTCRoomEventDelegate,RCRTCActivityMonitorDelegate>

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

/**
 liveurl
 */
@property (nonatomic , copy) NSString *liveUrl;


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
                [self alert:code];
            }];
            
            
        } else {
            NSLog(@"no users");
        }
    }
}
- (void)addCdn:(NSString *)addCdn completion:(void (^)(BOOL, RCRTCCode, NSArray *))completion{
    [self.liveInfo addPublishStreamUrl:addCdn completion:^(BOOL isSuccess, RCRTCCode code, NSArray * _Nonnull arr) {
        if (completion) {
            completion(isSuccess,code,arr);
        }
        [self alert:code];
    }];
}
- (void)removeCdn:(NSString *)cdn completion:(void (^)(BOOL, RCRTCCode, NSArray *))completion{
    [self.liveInfo removePublishStreamUrl:cdn completion:^(BOOL isSuccess, RCRTCCode code, NSArray * _Nonnull arr) {
        if (completion) {
            completion(isSuccess,code,arr);
        }
        [self alert:code];
    }];
}
- (RCRTCMixConfig *)setOutputConfig:(RCCRLiveLayoutModel *)model{
    RCRTCMixConfig *streamConfig = [[RCRTCMixConfig alloc] init];
    streamConfig.layoutMode = (int)model.layoutType ;
    // 默认大流输出画布大小
    streamConfig.mediaConfig.videoConfig.videoLayout.width = KWidth;
    streamConfig.mediaConfig.videoConfig.videoLayout.height = kHeight;
    streamConfig.mediaConfig.videoConfig.videoLayout.fps = 30;
    
    
    
    //    streamConfig.mediaConfig.audioConfig.bitrate = 300;
    //    streamConfig.mediaConfig.videoConfig.videoLayout.bitrate = 500;
    BOOL hasTiny = NO;
    if (model.layoutType == RCCRLiveLayoutTypeAdaptive) {
        streamConfig.mediaConfig.videoConfig.videoExtend.renderMode = model.adaptiveCrop ? 1:2;
        hasTiny = model.isPushTiny;
    }
    if (model.layoutType == RCCRLiveLayoutTypeSuspension) {
        streamConfig.mediaConfig.videoConfig.videoExtend.renderMode = model.suspensionCrop ?1:2;
        hasTiny = model.isPushTiny;
    }
    if (model.layoutType == RCCRLiveLayoutTypeCustom) {
        streamConfig.mediaConfig.videoConfig.videoExtend.renderMode = model.customCrop ?1:2;
        hasTiny = model.isPushTiny;
    }
    // 开启mcu推小流
    if (hasTiny) {
        // 小流布局
        streamConfig.mediaConfig.videoConfig.tinyVideoLayout.width = kTinyWidth;
        streamConfig.mediaConfig.videoConfig.tinyVideoLayout.height = KTinyHeight;
        streamConfig.mediaConfig.videoConfig.tinyVideoLayout.fps = KTinyFrame;
        streamConfig.mediaConfig.videoConfig.tinyVideoLayout.bitrate = KTinyBitrate;
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
        [self alert:code];

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
    [RCRTCEngine sharedInstance].monitorDelegate = self;
    self.liveUrl = liveUrl;
    [[RCRTCEngine sharedInstance] subscribeLiveStream:liveUrl streamType:RCRTCAVStreamTypeAudioVideo completion:^(RCRTCCode desc, RCRTCInputStream * _Nullable inputStream) {
        [self alert:desc];

        if (completion) {
            completion(desc,inputStream);
        }
    }];
}
- (void)exchangeSubscribeLiveStreamType:(RCCRExchangeType)type liveUrl:(NSString *)liveUrl completion:(void (^)(RCRTCCode desc, RCRTCInputStream * _Nullable inputStream))completion{
    self.liveUrl = liveUrl;
    [[RCRTCEngine sharedInstance] subscribeLiveStream:liveUrl streamType:(int)type completion:^(RCRTCCode desc, RCRTCInputStream * _Nullable inputStream) {
        [self alert:desc];

        if (completion) {
            completion(desc,inputStream);
        }
    }];
}
- (void)quitLive:(void (^)(BOOL isSuccess, RCRTCCode code))completion{
    [[RCRTCEngine sharedInstance] unsubscribeLiveStream:self.liveUrl completion:^(BOOL isSuccess, RCRTCCode code) {
        [self alert:code];

        if (completion) {
            completion(isSuccess,code);
        }
    }];
    
}
- (void)publishDefaultStreams:(void (^)(BOOL isSuccess,RCRTCCode desc , RCRTCLiveInfo * _Nullable liveHostModel))completion {
    [self.room.localUser publishDefaultLiveStreams:^(BOOL isSuccess, RCRTCCode desc, RCRTCLiveInfo * _Nullable liveInfo) {
        [self alert:desc];

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
        [self alert:desc];

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
        [self alert:desc];

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
        [self alert:desc];
        if (completion) {
            completion(isSuccess,desc);
        }
    }];
    
}
-(void)quitRoom:(NSString *)roomId completion:(void (^)(BOOL isSuccess))completion{
    [[RCRTCEngine sharedInstance] leaveRoom:roomId completion:^(BOOL isSuccess, RCRTCCode code) {
        [self alert:code];
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
-(void)didReportStatForm:(RCRTCStatisticalForm *)form{
    NSArray *arr = form.recvStats;
    if (arr.count > 0) {
        for (RCRTCStreamStat *stat in arr) {
            if ([stat.mediaType isEqualToString:RongRTCMediaTypeVideo]) {
                NSInteger width = stat.frameWidth;
                NSInteger height = stat.frameHeight;
                NSString *resolution = [NSString stringWithFormat:@"%@x%@",@(width),@(height)];
                NSInteger frame = stat.frameRate;
                float bitrate = stat.bitRate;
                NSString *frameStr = [NSString stringWithFormat:@"%@",@(frame)];
                NSString *bitrateStr = [NSString stringWithFormat:@"%.2f",bitrate];
                [self toReportVideoResolution:resolution frame:frameStr bitrate:bitrateStr];
                break;
            }
        }
    }
}
- (void)alert:(RCRTCCode)code{
    if (code != RCRTCCodeSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *str = [NSString stringWithFormat:@"RTC 层错误码:%@",@(code)];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误提示" message:str preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alert addAction:action];
            [self.chatVC presentViewController:alert animated:YES completion:nil];
        });
        
    }
}
- (void)toReportVideoResolution:(NSString *)resolution frame:(NSString *)frame bitrate:(NSString *)bitrate{
    if (self.delegate) {
        [self.delegate didReportVideoResolution:resolution frame:frame bitrate:bitrate];
    }
}
@end
