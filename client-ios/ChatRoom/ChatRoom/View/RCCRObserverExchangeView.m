//
//  RCCRObserverExchangeView.m
//  ChatRoom
//
//  Created by 孙承秀 on 2020/7/23.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCCRObserverExchangeView.h"
#import "RCLabel.h"
#import "RCButton.h"
#import "Masonry.h"
@implementation RCCRObserverExchangeView

- (instancetype)init{
    if (self = [super init]) {
        [self addSubviews];
    }
    return self;
}
- (void)addSubviews{
    NSArray *arr = @[@"拉音频",@"拉视频",@"拉大流",@"拉视频小流",@"拉音视频小流"];
    for (int i = 0; i < arr.count; i ++) {
        RCLabel *label = [[RCLabel alloc] init];
        [label makeConfig:^(RCLabel *lab) {
            lab.titleColor([UIColor whiteColor]).labelText(arr[i]);
            lab.titleFont([UIFont systemFontOfSize:14]);
        }];
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(i * 30 + 5);
            make.left.mas_equalTo(self).offset(5);
            make.height.mas_equalTo(@(30));
            make.width.mas_equalTo(@(100));
        }];
        
        RCButton *btn = [[RCButton alloc] init];
        [btn makeConfig:^(RCButton *btn) {
            btn.cornerRadiusNumber(8);
            btn.tag = i;
            btn.backgroundColor = [UIColor whiteColor];
            btn.addTarget(self,@selector(didClickBtn:));
        }];
        [self addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(i * 30 + 10);
            make.right.mas_equalTo(self).offset(-8);
            make.height.mas_equalTo(@(16));
            make.width.mas_equalTo(@(16));
        }];
    }
}
- (void)didClickBtn:(UIButton *)btn{
    for (UIView *sub in self.subviews) {
        if ([sub isKindOfClass:[UIButton class]]) {
            if (sub.tag == btn.tag) {
                sub.backgroundColor = [UIColor blueColor];
            } else {
                sub.backgroundColor = [UIColor whiteColor];
            }
        }
    }
    if (self.delegate) {
        [self.delegate didExchange:btn.tag];
    }
}
@end
