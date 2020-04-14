//
//  RCCRSettingCellProtocol.h
//  ChatRoom
//
//  Created by 孙承秀 on 2019/12/4.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RCCRSettingModel;
@class RCCRLiveLayoutModel;
@class RCCRSettingBaseTableViewCell;
NS_ASSUME_NONNULL_BEGIN

@protocol RCCRSettingCellProtocol <NSObject>
- (void)product:(RCCRSettingModel *)model;
@end


@protocol RCCRSettingCellReturnProtocol <NSObject>

- (void)didClickedCell:(UITableViewCell *)cell layout:(RCCRLiveLayoutModel *)model;
- (void)didTouchCell:(RCCRSettingBaseTableViewCell *)cell;
@end
NS_ASSUME_NONNULL_END
