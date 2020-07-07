//
//  RCCRCDNSelectViewController.h
//  ChatRoom
//
//  Created by 孙承秀 on 2020/5/29.
//  Copyright © 2020 罗骏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RCCRCDNSelectModel.h"
NS_ASSUME_NONNULL_BEGIN
@protocol RCCRSelectCDNProtocol;
@interface RCCRCDNSelectViewController : UIViewController

/**
 delegate
 */
@property(nonatomic , weak)id <RCCRSelectCDNProtocol> delegate;


/**
 model
 */
@property(nonatomic , strong)RCCRCDNSelectModel *model;
@end
@protocol RCCRSelectCDNProtocol <NSObject>

- (void)didSelectCDN:(NSArray *)list;

@end
NS_ASSUME_NONNULL_END
