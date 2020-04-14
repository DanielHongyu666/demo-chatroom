//
//  RCCRSettingTableView.h
//  ChatRoom
//
//  Created by 孙承秀 on 2019/12/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCCRSettingModel.h"
#import "RCCRSwitchProtocol.h"
NS_ASSUME_NONNULL_BEGIN
@protocol RCCRSettingTableViewDelegate;
@protocol RCCRSettingCellReturnProtocol;

@interface RCCRSettingTableView : UITableView<UITableViewDelegate , UITableViewDataSource>

/**
 delegate
 */
@property(nonatomic , weak)id <RCCRSettingTableViewDelegate> settingDelegate;

/**
 setting delegate
 */
@property(nonatomic , weak)id <RCCRSettingCellReturnProtocol> settingReturnDelegate;

/**
 setting model
 */
@property(nonatomic , strong)RCCRSettingModel *settingModel;
- (void)reloadDataWithType:(RCCRSwitchType)type;

@end
@protocol RCCRSettingTableViewDelegate <NSObject>

- (void)tableViewDidClosed:(UITableView *)tableView;

@end
NS_ASSUME_NONNULL_END
