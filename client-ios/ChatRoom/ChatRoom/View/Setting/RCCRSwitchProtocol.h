//
//  RCCRSwitchProtocol.h
//  ChatRoom
//
//  Created by 孙承秀 on 2019/12/3.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger , RCCRSwitchType) {
    /*
     自适应
     */
    RCCRSwitchTypeAdaptive,
    /*
     悬浮
     */
    RCCRSwitchTypeSuspension,
    /*
     自定义
     */
    RCCRSwitchTypeCustom
};
@protocol RCCRSwitchProtocol <NSObject>
- (void)didSelectSwitchView:(UIView *)view type:(RCCRSwitchType)type;
- (void)close;
@end

NS_ASSUME_NONNULL_END
