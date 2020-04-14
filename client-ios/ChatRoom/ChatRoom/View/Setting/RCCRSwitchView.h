//
//  RCCRSwitchView.h
//  ChatRoom
//
//  Created by 孙承秀 on 2019/12/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCCRSwitchProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCCRSwitchView : UIView
-(instancetype)initWithFrame:(CGRect)frame type:(RCCRSwitchType)type;
/**
 delegate
 */
@property(nonatomic , assign)id <RCCRSwitchProtocol> delegate;

/**
 type
 */
@property(nonatomic , assign , readonly)RCCRSwitchType type;
- (void)regain:(BOOL)regain;


@end
NS_ASSUME_NONNULL_END
