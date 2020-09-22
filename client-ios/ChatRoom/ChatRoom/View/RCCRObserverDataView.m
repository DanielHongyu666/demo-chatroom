//
//  RCCRObserverDataView.m
//  ChatRoom
//
//  Created by 孙承秀 on 2020/7/23.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCCRObserverDataView.h"
#import "RCLabel.h"
#import "RCButton.h"
#import "Masonry.h"
@interface RCCRObserverDataView()

/**
 video resolution
 
 */
@property (nonatomic , strong) RCLabel *resolutionLable;

/**
 video frame
 
 */
@property (nonatomic , strong) RCLabel *videoFrame;
/**
 video resolution
 
 */
@property (nonatomic , strong) RCLabel *videoBitrate;
@end
@implementation RCCRObserverDataView


- (instancetype)init{
    if (self = [super init]) {
        [self addSubviews];
    }
    return self;
}
- (void)addSubviews{
    NSArray *arr = @[@"视频分辨率：",@"视频码率：",@"视频帧率："];
    for (int i = 0; i < arr.count; i ++) {
        RCLabel *label = [[RCLabel alloc] init];
        [label makeConfig:^(RCLabel *lab) {
            lab.titleColor([UIColor whiteColor]).labelText(arr[i]);
            lab.titleFont([UIFont systemFontOfSize:8]);
        }];
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(i * 30);
            make.left.mas_equalTo(self);
            make.height.mas_equalTo(@(30));
            make.width.mas_equalTo(@(50));
        }];
        
        
        RCLabel *label1 = [[RCLabel alloc] init];
        [label1 makeConfig:^(RCLabel *lab) {
            lab.titleColor([UIColor whiteColor]).labelText(@"");
            lab.titleFont([UIFont systemFontOfSize:10]);
        }];
        [self addSubview:label1];
        [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(i * 30 );
            make.left.mas_equalTo(label.mas_right).offset(1);
            make.height.mas_equalTo(@(30));
            make.width.mas_equalTo(@(50));
        }];
        if (i == 0) {
            self.resolutionLable = label1;
        }
        if (i == 1) {
            self.videoBitrate = label1;
        }
        if (i == 2) {
            self.videoFrame = label1;
        }
    }
}
- (void)setVideoResolution:(NSString *)resolution videoBitrate:(NSString *)bitrate videoFrame:(NSString *)videoFrame{
    self.resolutionLable.text = resolution;
    self.videoBitrate.text = bitrate;
    self.videoFrame.text = videoFrame;
}

@end
