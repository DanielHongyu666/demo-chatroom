//
//  RCCRHostInformationView.h
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/10.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCCRLiveModel.h"

@protocol RCCRHostInformationViewDelegate <NSObject>
@optional

- (void)clickAttentionBtn:(UIButton *)sender;

@end

@interface RCCRHostInformationView : UIView

/**
 数据模型
 */
@property (nonatomic, strong) RCCRLiveModel *hostModel;

@property (nonatomic, weak) id<RCCRHostInformationViewDelegate> delegate;

- (instancetype)initWithModel:(RCCRLiveModel *)model;

- (void)setDataModel:(RCCRLiveModel *)model;

/**
 关注按钮
 */
@property (nonatomic, strong) UIButton *attentionBtn;

@end
