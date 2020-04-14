//
//  RCCRSettingBaseTableViewCell.h
//  ChatRoom
//
//  Created by 孙承秀 on 2019/12/4.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCCRSettingCellProtocol.h"
#import "RCCRLiveLayoutModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCCRSettingBaseTableViewCell : UITableViewCell<RCCRSettingCellProtocol , RCCRSettingCellReturnProtocol>

/**
 delegate
 */
@property(nonatomic , weak)id<RCCRSettingCellReturnProtocol> returnDelegate;

/**
 layout model
 */
@property(nonatomic , strong )RCCRLiveLayoutModel *layoutModel;

/**
 tableview
 */
@property(nonatomic , weak)UITableView *tableView;


@end

NS_ASSUME_NONNULL_END
