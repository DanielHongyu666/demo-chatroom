//
//  RCCRSwitchView.m
//  ChatRoom
//
//  Created by 孙承秀 on 2019/12/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCCRSwitchView.h"
#define CLICKBTNWIDTH 16
@interface RCCRSwitchView()

/**
 clickBtn
 */
@property(nonatomic , strong)UIButton *clickBtn;

/**
 label
 */
@property(nonatomic , strong)UILabel *label;

/**
 name
 */
@property(nonatomic , copy)NSString *name;

/**
 ges
 */
@property(nonatomic , strong)UITapGestureRecognizer *tap;
@end
@implementation RCCRSwitchView
@synthesize type = _type;
-(instancetype)initWithFrame:(CGRect)frame type:(RCCRSwitchType)type{
    if (self = [super initWithFrame:frame]) {
        _type = type;
        switch (type) {
            case RCCRSwitchTypeAdaptive:
                self.name =  @"自适应布局";
                break;
                case RCCRSwitchTypeSuspension:
                self.name = @"悬浮布局";
                break;
                case RCCRSwitchTypeCustom:
                self.name = @"自定义布局";
                break;
            default:
                 self.name =  @"自适应布局";
                break;
        }
        [self setUserInteractionEnabled:YES];
        [self addSubviews];

    }
    return self;
}
- (void)addSubviews{
    [self addSubview:self.clickBtn];
    [self addSubview:self.label];
}
- (void)didClickedBtn:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        return;
    }
    btn.selected = !btn.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectSwitchView:type:)]) {
           [self.delegate didSelectSwitchView:self type:self.type];
       }
}
- (void)tapLabel{
    if (self.clickBtn.selected) {
        return;
    }
    self.clickBtn.selected = !self.clickBtn.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectSwitchView:type:)]) {
        [self.delegate didSelectSwitchView:self type:self.type];
    }
}
-(void)regain:(BOOL)regain{
    self.clickBtn.selected = !regain;
}
-(UIButton *)clickBtn{
    if (!_clickBtn) {
        _clickBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 2, CLICKBTNWIDTH, CLICKBTNWIDTH)];
        [_clickBtn setBackgroundImage:[UIImage imageNamed:@"未选中"] forState:UIControlStateNormal];
        [_clickBtn setBackgroundImage:[UIImage imageNamed:@"选中"] forState:UIControlStateSelected];
        [_clickBtn addTarget:self action:@selector(didClickedBtn:) forControlEvents:UIControlEventTouchUpInside];
//        [_clickBtn setBackgroundColor:[UIColor redColor]];
    }
    return _clickBtn;
}
-(UILabel *)label{
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(self.clickBtn.frame.size.width + self.clickBtn.frame.origin.x + 6, 0, self.frame.size.width - (CLICKBTNWIDTH), 20)];
        [_label setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:14]];
        [_label setText:self.name];
//        [_label setBackgroundColor:[UIColor blueColor]];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [_label setUserInteractionEnabled:YES];
        [_label addGestureRecognizer:self.tap];
//        [_label sizeToFit];
    }
    return _label;
}
-(UITapGestureRecognizer *)tap{
    if (!_tap) {
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLabel)];
    }
    return _tap;
}
@end
