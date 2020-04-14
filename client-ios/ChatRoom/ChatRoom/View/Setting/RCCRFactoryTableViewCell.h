//
//  RCCRFactoryTableViewCell.h
//  ChatRoom
//
//  Created by 孙承秀 on 2019/12/3.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCCRSwitchProtocol.h"
#import "RCCRAdaptiveTableViewCell.h"
#import "RCCRSuspensionTableViewCell.h"
#import "RCCRCustomTableViewCell.h"
#import "RCCRSettingModel.h"
NS_ASSUME_NONNULL_BEGIN
#define ADAPTIVECELLID @"AdaptiveCell"
#define SUSPENSIONCELLID @"SuspensionCell"
#define CUSTOMCELLID @"CustomCell"
@class RCCRSettingBaseTableViewCell;
@interface RCCRFactoryTableViewCell : UITableViewCell
- (RCCRFactoryTableViewCell *)createCellWithTableView:(UITableView *)tableView cellType:(RCCRSwitchType)type;
-(void)process:(RCCRSettingModel *)model;
- (RCCRSettingBaseTableViewCell *)product;
@end

NS_ASSUME_NONNULL_END
