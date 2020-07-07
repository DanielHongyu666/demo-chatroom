//
//  RCCRCDNAddStreamView.h
//  ChatRoom
//
//  Created by 孙承秀 on 2020/5/25.
//  Copyright © 2020 罗骏. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RCCRCDNPublishViewProtocol;
NS_ASSUME_NONNULL_BEGIN

@interface RCCRCDNAddStreamView : UIView

/**
 delegate
 */
@property(nonatomic , weak)id <RCCRCDNPublishViewProtocol> delegate;

@end
@protocol RCCRCDNPublishViewProtocol <NSObject>

- (void)didAddCDNAddress:(NSDictionary *)cdn;
- (void)didClickClose;

@end
NS_ASSUME_NONNULL_END
