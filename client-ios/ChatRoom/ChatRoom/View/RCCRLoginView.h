//
//  RCCRLoginView.h
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/11.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RCCRLoginViewDelegate <NSObject>

@optional

- (void)clickLoginBtn:(UIButton *)loginBtn;

@end

@interface RCCRLoginView : UIView

@property (nonatomic, weak) id<RCCRLoginViewDelegate> delegate;

@end
