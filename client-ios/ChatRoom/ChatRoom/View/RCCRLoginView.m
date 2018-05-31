//
//  RCCRLoginView.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/11.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "RCCRLoginView.h"


@interface RCCRLoginView ()

@property (nonatomic, strong) UILabel *titleLbl;

@property (nonatomic, strong) UIButton *loginBtn;

@end

@implementation RCCRLoginView

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self initializedSubViews];
}

- (void)loginClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(clickLoginBtn:)]) {
        [self.delegate clickLoginBtn:sender];
    }
}

- (void)initializedSubViews {
    [self addSubview:self.titleLbl];
    CGSize size = self.bounds.size;
    [_titleLbl setFrame:CGRectMake((size.width - 200)/2, 40, 200, 30)];
    
    [self addSubview:self.loginBtn];
    [_loginBtn setFrame:CGRectMake((size.width - 200)/2, 100, 200, 60)];
    [_loginBtn.layer setCornerRadius:4];
    [_loginBtn.layer setMasksToBounds:YES];
}

- (UILabel *)titleLbl {
    if (!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        [_titleLbl setTextAlignment:NSTextAlignmentCenter];
        [_titleLbl setFont:[UIFont systemFontOfSize:20.0f]];
        [_titleLbl setNumberOfLines:1];
        [_titleLbl setTextColor:[UIColor whiteColor]];
        [_titleLbl setText:@"登录后可发送消息"];
    }
    return  _titleLbl;
}

- (UIButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [[UIButton alloc] init];
        [_loginBtn addTarget:self action:@selector(loginClick:) forControlEvents:UIControlEventTouchUpInside];
        [_loginBtn setTitle:@"立即登录" forState:UIControlStateNormal];
        [_loginBtn setBackgroundColor:[UIColor whiteColor]];
        [_loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return  _loginBtn;
}

@end
