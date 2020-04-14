//
//  RCCRBackgroundView.h
//  ChatRoom
//
//  Created by 孙承秀 on 2019/9/4.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@protocol RCConnectDelegate;
@interface RCCRBackgroundView : UIView

/**
 delegate
 */
@property(nonatomic , weak)id <RCConnectDelegate> delegate;

- (void)present;
- (void)dismiss;
@end
@protocol RCConnectDelegate <NSObject>

- (void)connectSuccess;
- (void)touchedBackgroundView;
@end
NS_ASSUME_NONNULL_END
