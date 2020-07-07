//
//  RCCRCDNListTableView.h
//  ChatRoom
//
//  Created by 孙承秀 on 2020/5/25.
//  Copyright © 2020 罗骏. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol RCCRListTableViewProtocol ;
@interface RCCRCDNListTableView : UITableView

/**
 delegate
 */
@property(nonatomic , weak)id <RCCRListTableViewProtocol> listDelegate;

- (void)addCDN:(NSDictionary *)cdn;
- (CGFloat)height;
@end
@protocol RCCRListTableViewProtocol <NSObject>

- (void)didUpdateHeight;
- (void)didRemoveCDN:(NSDictionary *)cdn;

@end
NS_ASSUME_NONNULL_END
