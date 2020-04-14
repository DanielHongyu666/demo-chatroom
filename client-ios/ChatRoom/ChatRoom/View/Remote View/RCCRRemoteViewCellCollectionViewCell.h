//
//  RCCRRemoteViewCellCollectionViewCell.h
//  ChatRoom
//
//  Created by 孙承秀 on 2019/8/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCCRRemoteModel.h"
#import <RongRTCLib/RongRTCLib.h>
NS_ASSUME_NONNULL_BEGIN

@interface RCCRRemoteViewCellCollectionViewCell : UICollectionViewCell

/**
 model
 */
@property(nonatomic , strong)RCCRRemoteModel *remoteModel;

/**
 remote view
 */
@property(nonatomic , strong , nullable)RongRTCRemoteVideoView *remoteView;

/**
 username label
 */
@property(nonatomic , strong)UILabel *userNameLabel;
- (void)addLocalView:(RongRTCLocalVideoView *)localView;
- (void)addRemoteVideoView:(RongRTCRemoteVideoView *)remoteVideoView;
@end

NS_ASSUME_NONNULL_END
