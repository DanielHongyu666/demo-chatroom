//
//  RCCRCDNViewController.h
//  ChatRoom
//
//  Created by 孙承秀 on 2020/5/25.
//  Copyright © 2020 罗骏. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol RCCRCDNProtocol ;
@interface RCCRCDNViewController : UIViewController

/**
 cdm
 */
@property(nonatomic , assign)id <RCCRCDNProtocol> delegate;

@end
@protocol RCCRCDNProtocol <NSObject>

- (void)didAddCDN:(NSString *)cdn controller:(UIViewController *)vc;
- (void)didRemoveCDN:(NSString *)cdn controller:(UIViewController *)vc;

@end
NS_ASSUME_NONNULL_END
