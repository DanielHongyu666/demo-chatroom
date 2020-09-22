//
//  RCCRObserverExchangeView.h
//  ChatRoom
//
//  Created by 孙承秀 on 2020/7/23.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCCRUtilities.h"
NS_ASSUME_NONNULL_BEGIN

@protocol RCCRExchangeProtocol;
@interface RCCRObserverExchangeView : UIView

/**
 delegate
 */
@property (nonatomic , assign) id<RCCRExchangeProtocol> delegate;

@end
@protocol RCCRExchangeProtocol <NSObject>

- (void)didExchange:(RCCRExchangeType)type;

@end
NS_ASSUME_NONNULL_END
