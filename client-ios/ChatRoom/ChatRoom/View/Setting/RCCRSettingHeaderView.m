//
//  RCCRSettingHeaderView.m
//  ChatRoom
//
//  Created by 孙承秀 on 2019/12/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCCRSettingHeaderView.h"
#import "UIColor+Helper.h"
#import "RCCRSwitchView.h"
#define PRE 15
#define FIX 41.5
#define SWITCHWIDTH ((self.frame.size.width - PRE * 2 - FIX * 2) / 3)
@interface RCCRSettingHeaderView()<RCCRSwitchProtocol>

/**
 view
 */
@property(nonatomic , strong)UIView *backView;

/**
 line
 */
@property(nonatomic , strong)UILabel *line;

/**
 switchView
 */
@property(nonatomic , strong)RCCRSwitchView *adaptiveSwitchView;
/**
 switchView
 */
@property(nonatomic , strong)RCCRSwitchView *suspensionSwitchView;
/**
 switchView
 */
@property(nonatomic , strong)RCCRSwitchView *customSwitchView;

/**
 preView
 */
@property(nonatomic , strong)RCCRSwitchView *preView;

/**
 title
 */
@property(nonatomic , strong)UILabel *titleLabel;

/**
 close
 */
@property(nonatomic , strong)UIButton *close;
@end
@implementation RCCRSettingHeaderView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [self addViews];
    }
    return self;
}
- (void)addViews{
    self.clipsToBounds = YES;
    [self addSubview:self.backView];
    [self.backView addSubview:self.titleLabel];
    [self.backView addSubview:self.line];
    [self addSubview:self.adaptiveSwitchView];
    [self addSubview:self.suspensionSwitchView];
    [self addSubview:self.customSwitchView];
    [self addSubview:self.close];
    // 先选中一个
    [self.suspensionSwitchView regain:NO];
    self.preView = self.suspensionSwitchView;
}
- (void)selectViewWithType:(RCCRSwitchType)type{
    [self.preView regain:YES];
    switch (type) {
        case RCCRSwitchTypeSuspension:
        {
            [self.suspensionSwitchView regain:NO];
            self.preView = self.suspensionSwitchView;
        }
            break;
        case RCCRSwitchTypeAdaptive:{
            [self.adaptiveSwitchView regain:NO];
            self.preView = self.adaptiveSwitchView;
        }
            break;
            case RCCRSwitchTypeCustom:
        {
            [self.customSwitchView regain:NO];
            self.preView = self.customSwitchView;
        }
        default:
            break;
    }
}
-(UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height + 10)];
        _backView.backgroundColor = [UIColor whiteColor];
        _backView.layer.cornerRadius = 10;
        _backView.layer.masksToBounds = YES;
    }
    return _backView;
}
-(UILabel *)line{
    if (!_line) {
        _line = [[UILabel alloc] initWithFrame:CGRectMake(0, 34.5, self.frame.size.width, 1)];
        [_line setBackgroundColor:[UIColor colorWithHexString:@"0xd8d8d8" alpha:1.0]];
    }
    return _line;
}
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - 84) / 2, 10, 84, 20)];
        [_titleLabel setText:@"混流布局设置"];
        [_titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:14]];
    }
    return _titleLabel;
}
-(UIButton *)close{
    if (!_close) {
        _close = [[UIButton alloc] initWithFrame:CGRectMake((self.frame.size.width - 35), 0, 35, 35)];
        [_close setImage:[UIImage imageNamed:@"关闭"] forState:UIControlStateNormal];
        [_close addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _close;
}
-(RCCRSwitchView *)adaptiveSwitchView{
    if (!_adaptiveSwitchView) {
        _adaptiveSwitchView = [[RCCRSwitchView alloc] initWithFrame:CGRectMake(PRE, 50, SWITCHWIDTH, 20) type:RCCRSwitchTypeAdaptive];
        _adaptiveSwitchView.delegate = self;
    }
    return _adaptiveSwitchView;
}
-(RCCRSwitchView *)suspensionSwitchView{
    if (!_suspensionSwitchView) {
        _suspensionSwitchView = [[RCCRSwitchView alloc] initWithFrame:CGRectMake(self.adaptiveSwitchView.frame.origin.x + self.adaptiveSwitchView.frame.size.width + FIX, 50, SWITCHWIDTH, 20) type:RCCRSwitchTypeSuspension];
        _suspensionSwitchView.delegate = self;
    }
    return _suspensionSwitchView;
}
-(RCCRSwitchView *)customSwitchView{
    if (!_customSwitchView) {
        _customSwitchView = [[RCCRSwitchView alloc] initWithFrame:CGRectMake(self.suspensionSwitchView.frame.origin.x + self.suspensionSwitchView.frame.size.width + FIX, 50, SWITCHWIDTH, 20) type:RCCRSwitchTypeCustom];
        _customSwitchView.delegate = self;
    }
    return _customSwitchView;
}
- (void)closeView{
    if (self.delegate && [self.delegate respondsToSelector:@selector(close)]) {
        [self.delegate close];
    }
}
-(void)didSelectSwitchView:(RCCRSwitchView *)view type:(RCCRSwitchType)type{
    if (self.preView) {
        [self.preView regain:YES];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectSwitchView:type:)]) {
        [self.delegate didSelectSwitchView:view type:type];
    }
    self.preView = view;
    
}
@end
