//
//  RCCRHostInformationView.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/10.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "RCCRHostInformationView.h"

@interface RCCRHostInformationView ()

@property (nonatomic, strong) UIImageView *portraitView;

@property (nonatomic, strong) UILabel *nameLbl;

@property (nonatomic, strong) UILabel *fansLbl;

@property (nonatomic, strong) UILabel *praiseLbl;

@property (nonatomic, strong) UILabel *giftLbl;

@property (nonatomic, strong) UILabel *attentionLbl;

@end

@implementation RCCRHostInformationView

- (instancetype)initWithModel:(RCCRLiveModel *)model {
    self = [super init];
    if (self) {
        self = [super init];
        self.hostModel = model;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self initializedSubViews];
}

- (void)setDataModel:(RCCRLiveModel *)model {
    self.hostModel = model;
    
    [_portraitView setImage:[UIImage imageNamed:model.hostPortrait]];
    
    [_nameLbl setText:model.hostName];
    [_fansLbl setText:[NSString stringWithFormat:@"粉丝：%ld",(long)model.fansAmount]];
    [_praiseLbl setText:[NSString stringWithFormat:@"获赞：%ld",(long)model.praiseAmount]];
    [_giftLbl setText:[NSString stringWithFormat:@"礼物：%ld",(long)model.giftAmount]];
    [_attentionLbl setText:[NSString stringWithFormat:@"关注：%ld",(long)model.attentionAmount]];
}

- (void)attentionBtnClick:(UIButton *)sender {
    NSLog(@"点击了关注");
    if ([self.delegate respondsToSelector:@selector(clickAttentionBtn:)]) {
        [self.delegate clickAttentionBtn:sender];
    }
}

- (void)initializedSubViews {
    CGFloat width = self.bounds.size.width;
    [self addSubview:self.portraitView];
    [_portraitView setFrame:CGRectMake((width - 100 - 20)/2, 20, 20, 20)];
    [_portraitView.layer setCornerRadius:10];
    [_portraitView.layer setMasksToBounds:YES];
    
    [self addSubview:self.nameLbl];
    [_nameLbl setFrame:CGRectMake((width - 100)/2, 20, 100, 20)];
    
    [self addSubview:self.fansLbl];
    [_fansLbl setFrame:CGRectMake(width/2 - 10 - 150, 60, 150, 20)];
    
    [self addSubview:self.praiseLbl];
    [_praiseLbl setFrame:CGRectMake(width/2 + 10, 60, 150, 20)];
    
    [self addSubview:self.giftLbl];
    [_giftLbl setFrame:CGRectMake(width/2 - 10 - 150, 100, 150, 20)];
    
    [self addSubview:self.attentionLbl];
    [_attentionLbl setFrame:CGRectMake(width/2 + 10, 100, 150, 20)];
    
    [self addSubview:self.attentionBtn];
    [_attentionBtn setFrame:CGRectMake((width - 80)/2, 170, 80, 20)];
    
}

- (UIImageView *)portraitView {
    if (!_portraitView) {
        _portraitView = [[UIImageView alloc] init];
    }
    return _portraitView;
}

- (UILabel *)nameLbl {
    if (!_nameLbl) {
        _nameLbl = [[UILabel alloc] init];
        [_nameLbl setTextAlignment:NSTextAlignmentCenter];
        [_nameLbl setFont:[UIFont systemFontOfSize:18.0f]];
        [_nameLbl setNumberOfLines:1];
        [_nameLbl setTextColor:[UIColor whiteColor]];
    }
    return  _nameLbl;
}

- (UILabel *)fansLbl {
    if (!_fansLbl) {
        _fansLbl = [[UILabel alloc] init];
        [_fansLbl setTextAlignment:NSTextAlignmentCenter];
        [_fansLbl setFont:[UIFont systemFontOfSize:18.0f]];
        [_fansLbl setNumberOfLines:1];
        [_fansLbl setTextColor:[UIColor whiteColor]];
    }
    return  _fansLbl;
}

- (UILabel *)praiseLbl {
    if (!_praiseLbl) {
        _praiseLbl = [[UILabel alloc] init];
        [_praiseLbl setTextAlignment:NSTextAlignmentCenter];
        [_praiseLbl setFont:[UIFont systemFontOfSize:18.0f]];
        [_praiseLbl setNumberOfLines:1];
        [_praiseLbl setTextColor:[UIColor whiteColor]];
    }
    return  _praiseLbl;
}

- (UILabel *)giftLbl {
    if (!_giftLbl) {
        _giftLbl = [[UILabel alloc] init];
        [_giftLbl setTextAlignment:NSTextAlignmentCenter];
        [_giftLbl setFont:[UIFont systemFontOfSize:18.0f]];
        [_giftLbl setNumberOfLines:1];
        [_giftLbl setTextColor:[UIColor whiteColor]];
    }
    return  _giftLbl;
}

- (UILabel *)attentionLbl {
    if (!_attentionLbl) {
        _attentionLbl = [[UILabel alloc] init];
        [_attentionLbl setTextAlignment:NSTextAlignmentCenter];
        [_attentionLbl setFont:[UIFont systemFontOfSize:18.0f]];
        [_attentionLbl setNumberOfLines:1];
        [_attentionLbl setTextColor:[UIColor whiteColor]];
    }
    return  _attentionLbl;
}

- (UIButton *)attentionBtn {
    if (!_attentionBtn) {
        _attentionBtn = [[UIButton alloc] init];
        [_attentionBtn addTarget:self action:@selector(attentionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_attentionBtn setTitle:@"+ 关注" forState:UIControlStateNormal];
        [_attentionBtn setTitle:@"已关注" forState:UIControlStateSelected];
        [_attentionBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    return  _attentionBtn;
}

@end
