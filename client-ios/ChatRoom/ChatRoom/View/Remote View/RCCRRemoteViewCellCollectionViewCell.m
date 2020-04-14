//
//  RCCRRemoteViewCellCollectionViewCell.m
//  ChatRoom
//
//  Created by 孙承秀 on 2019/8/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCCRRemoteViewCellCollectionViewCell.h"

@implementation RCCRRemoteViewCellCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.remoteView];
        [self addSubview:self.userNameLabel];
    }
    return self;
}
-(void)setRemoteModel:(RCCRRemoteModel *)remoteModel{
    _remoteModel = remoteModel;
    [self.userNameLabel setText:remoteModel.userName];
    if (remoteModel.inputStream) {
        [remoteModel.inputStream setVideoRender:self.remoteView];
    }
}
- (void)addLocalView:(RongRTCLocalVideoView *)localView{
    localView.frame = CGRectMake(5, 5, self.contentView.bounds.size.width - 10, self.contentView.bounds.size.height - 10);
    [self addSubview:localView];
    self.userNameLabel.text = @"自己";
    [self bringSubviewToFront:self.userNameLabel];
}
- (void)addRemoteVideoView:(RongRTCRemoteVideoView *)remoteVideoView{
    remoteVideoView.frame = CGRectMake(5, 5, self.contentView.bounds.size.width - 10, self.contentView.bounds.size.height - 10);
    [self addSubview:remoteVideoView];
    self.userNameLabel.text = self.remoteModel.userName;
    [self bringSubviewToFront:self.userNameLabel];
}
-(RongRTCRemoteVideoView *)remoteView{
    if (!_remoteView) {
        _remoteView = [[RongRTCRemoteVideoView alloc] initWithFrame:CGRectMake(5, 5, self.contentView.bounds.size.width - 10, self.contentView.bounds.size.height - 10)];
        [_remoteView setFillMode:RCVideoFillModeAspectFill];
//        [_remoteView setBackgroundColor:[UIColor redColor]];
    }
    return _remoteView;
}

-(UILabel *)userNameLabel{
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, self.contentView.frame.size.width - 10, 20)];
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
