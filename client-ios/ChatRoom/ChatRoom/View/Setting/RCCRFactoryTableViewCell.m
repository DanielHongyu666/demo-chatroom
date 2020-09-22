//
//  RCCRFactoryTableViewCell.m
//  ChatRoom
//
//  Created by 孙承秀 on 2019/12/3.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCCRFactoryTableViewCell.h"
#import "RCCRSettingBaseTableViewCell.h"
@interface RCCRFactoryTableViewCell()

/**
 base cell
 */
@property(nonatomic , strong)RCCRSettingBaseTableViewCell *productCell;
@end
@implementation RCCRFactoryTableViewCell
- (RCCRFactoryTableViewCell *)createCellWithTableView:(UITableView *)tableView cellType:(RCCRSwitchType)type{
    RCCRSettingBaseTableViewCell *cell = nil;
    switch (type) {
        case RCCRSwitchTypeAdaptive:
        {
            cell = (RCCRAdaptiveTableViewCell *)[tableView dequeueReusableCellWithIdentifier:ADAPTIVECELLID];
        }
            break;
        case RCCRSwitchTypeSuspension:{
            cell = (RCCRSuspensionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:SUSPENSIONCELLID];
        }
            break;
        case RCCRSwitchTypeCustom:
        {
            cell = (RCCRCustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CUSTOMCELLID];
        }
            break;
            
        default:
            break;
    }
    self.productCell = cell;
    return self;
}
-(void)process:(RCCRSettingModel *)model{
    [self.productCell product:model];
}
-(RCCRSettingBaseTableViewCell *)product{
    return self.productCell;
}
@end
