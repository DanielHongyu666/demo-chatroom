//
//  RCCRSendPrizeView.h
//  ChatRoom
//
//  Created by RongCloud on 2018/5/11.
//  Copyright © 2018年 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCCRGiftModel.h"

@protocol RCCRGiftViewDelegate <NSObject>
@optional

- (void)sendGift:(RCCRGiftModel *)giftModel;

@end

@interface RCCRGiftListView : UIView

@property (nonatomic, weak) id<RCCRGiftViewDelegate> delegate;

- (void)setModelArray:(NSArray<RCCRGiftModel *> *)modelArray;

@end
