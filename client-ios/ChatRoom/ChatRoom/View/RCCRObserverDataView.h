//
//  RCCRObserverDataView.h
//  ChatRoom
//
//  Created by 孙承秀 on 2020/7/23.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCCRUtilities.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCCRObserverDataView : UIView
- (void)setVideoResolution:(NSString *)resolution videoBitrate:(NSString *)bitrate videoFrame:(NSString *)videoFrame;
@end

NS_ASSUME_NONNULL_END
