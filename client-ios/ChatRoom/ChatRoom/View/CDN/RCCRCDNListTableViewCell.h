//
//  RCCRCDNListTableViewCell.h
//  ChatRoom
//
//  Created by 孙承秀 on 2020/5/25.
//  Copyright © 2020 罗骏. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol RCCRListCellProtocol;
@interface RCCRCDNListTableViewCell : UITableViewCell

/**
 delegate
 */
@property(nonatomic , assign)id <RCCRListCellProtocol> delegate;

- (void)configWithCdn:(NSDictionary *)cdn;
@end
@protocol RCCRListCellProtocol <NSObject>

- (void)didDeleteCell:(RCCRCDNListTableViewCell *)cell;
- (void)didCopyCell:(RCCRCDNListTableViewCell *)cell;
@end
NS_ASSUME_NONNULL_END
