//
//  RCCRLiveViewController.h
//  ChatRoom
//
//  Created by 孙承秀 on 2019/9/4.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCCRLiveModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCCRLiveViewController : UIViewController

/**
 完成回调
 */
@property(nonatomic , copy)void (^CompletionBlock)(NSString *roomId , RCCRLiveModel *model);

@end

NS_ASSUME_NONNULL_END
