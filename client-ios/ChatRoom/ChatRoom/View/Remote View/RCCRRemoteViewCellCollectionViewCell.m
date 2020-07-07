//
//  RCCRRemoteViewCellCollectionViewCell.m
//  ChatRoom
//
//  Created by 孙承秀 on 2019/8/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCCRRemoteViewCellCollectionViewCell.h"
@interface RCCRRemoteViewCellCollectionViewCell()

/**
 remote view
 */
@property(nonatomic , strong , nullable)RCRTCRemoteVideoView *remoteVideoView;
/**
 remote view
 */
@property(nonatomic , strong , nullable)RCRTCLocalVideoView *localVideoView;
@end
@implementation RCCRRemoteViewCellCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.remoteVideoView];
        [self addSubview:self.localVideoView];
        [self addSubview:self.userNameLabel];
    }
    return self;
}
-(void)setRemoteModel:(RCCRRemoteModel *)remoteModel{
    if ([remoteModel.inputStream isKindOfClass:[RCRTCInputStream class]]) {
        self.localVideoView.hidden = YES;
        self.remoteVideoView.hidden = NO;
        self.remoteView = self.remoteVideoView;
    } else {
        self.remoteVideoView.hidden = YES;
        self.localVideoView.hidden = NO;
        self.remoteView = self.localVideoView;
        [self.localVideoView flushVideoView];
    }
    _remoteModel = remoteModel;
    [self.userNameLabel setText:remoteModel.userName];
    if (remoteModel.inputStream) {
        if ([remoteModel.inputStream isKindOfClass:[RCRTCVideoInputStream class]]) {
            [(RCRTCVideoInputStream *)remoteModel.inputStream setVideoView:self.remoteVideoView];
        } else {
            [(RCRTCVideoOutputStream *)remoteModel.inputStream setVideoView:self.localVideoView];
        }
        
    }
}
- (void)addLocalView:(RCRTCLocalVideoView *)localView{
    localView.frame = CGRectMake(0, 0, self.contentView.bounds.size.width , self.contentView.bounds.size.height );
    [self addSubview:localView];
    self.userNameLabel.text = @"自己";
    [self bringSubviewToFront:self.userNameLabel];
}
- (void)addRemoteVideoView:(RCRTCRemoteVideoView *)remoteVideoView{
    remoteVideoView.frame = CGRectMake(0, 0, self.contentView.bounds.size.width , self.contentView.bounds.size.height );
    [self addSubview:remoteVideoView];
    self.userNameLabel.text = self.remoteModel.userName;
    [self bringSubviewToFront:self.userNameLabel];
}
-(RCRTCRemoteVideoView *)remoteVideoView{
    if (!_remoteVideoView) {
            _remoteVideoView = [[RCRTCRemoteVideoView alloc] initWithFrame:CGRectMake(0,0, self.contentView.bounds.size.width , self.contentView.bounds.size.height )];
        [_remoteVideoView setFillMode:RCRTCVideoFillModeAspectFill];
    //        [_remoteView setBackgroundColor:[UIColor redColor]];
        }
        return _remoteVideoView;
}
-(RCRTCLocalVideoView *)localVideoView{
    if (!_localVideoView) {
        _localVideoView = [[RCRTCLocalVideoView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.bounds.size.width , self.contentView.bounds.size.height )];
        [_localVideoView setFillMode:RCRTCVideoFillModeAspect];
    }
    return _localVideoView;
}
-(UILabel *)userNameLabel{
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 20)];
        [_userNameLabel setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
        [_userNameLabel setFont:[UIFont systemFontOfSize:10]];
        [_userNameLabel setTextColor:[UIColor whiteColor]];
        [_userNameLabel setTextAlignment:(NSTextAlignmentLeft)];
    }
    return _userNameLabel;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
  
   
    return NO;
}

@end
