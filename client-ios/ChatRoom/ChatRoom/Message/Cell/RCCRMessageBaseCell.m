//
//  RCCRMessageBaseCell.m
//  ChatRoom
//
//  Created by RongCloud on 2018/5/10.
//  Copyright © 2018年 rongcloud. All rights reserved.
//

#import "RCCRMessageBaseCell.h"

@implementation RCCRMessageBaseCell

- (void)setDataModel:(RCCRMessageModel *)model {
    self.model = model;
    [self setBaseAutoLayout];
}

- (void)setBaseAutoLayout {
 
}

@end
