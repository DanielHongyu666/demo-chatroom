//
//  RCCRSettingViewController.h
//  ChatRoom
//
//  Created by 孙承秀 on 2019/12/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCCRLiveLayoutModel.h"
#import "RCCRSettingModel.h"
typedef void (^SettingClickSaveBlock)(RCCRLiveLayoutModel *model);
NS_ASSUME_NONNULL_BEGIN

@interface RCCRSettingViewController : UIViewController

/**
 click block
 */
@property(nonatomic , copy)SettingClickSaveBlock clickSaveBlock;

/**
 setting model
 */
@property(nonatomic , strong)RCCRSettingModel *settingModel;
@end

NS_ASSUME_NONNULL_END
