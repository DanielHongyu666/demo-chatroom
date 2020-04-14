//
//  RCCRSettingHeaderView.h
//  ChatRoom
//
//  Created by 孙承秀 on 2019/12/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCCRSwitchProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCCRSettingHeaderView : UIView
-(instancetype)initWithFrame:(CGRect)frame switchType:(RCCRSwitchType)type;

/**
 delegate
 */
@property(nonatomic , weak)id<RCCRSwitchProtocol> delegate;
- (void)selectViewWithType:(RCCRSwitchType)type;
@end

NS_ASSUME_NONNULL_END
