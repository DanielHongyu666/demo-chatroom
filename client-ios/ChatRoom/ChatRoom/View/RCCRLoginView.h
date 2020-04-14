//
//  RCCRLoginView.h
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/11.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCCRLiveModel.h"
@protocol RCCRLoginViewDelegate <NSObject>

@optional

- (void)clickLoginBtn:(UIButton *)loginBtn userName:(NSString *)userName model:(RCCRLiveModel *)model;

@end

@interface RCCRLoginView : UIView
- (void)addObserver;
- (void)removeObserver;
@property (nonatomic, weak) id<RCCRLoginViewDelegate> delegate;

@end
