//
//  RCCRAudienceViewCell.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/17.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "RCCRAudienceViewCell.h"

@interface RCCRAudienceViewCell ()

@property (nonatomic, strong) RCCRAudienceModel *model;

@property (nonatomic, strong) UIImageView *portraitView;

@property (nonatomic, strong) UILabel *nameLbl;

/**
 invite btn
 */
@property(nonatomic , strong)UIButton *inviteBtn;

@end

@implementation RCCRAudienceViewCell

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self initializedSubViews];
}

- (void)setDataModel:(RCCRAudienceModel *)model {
    self.model = model;
    
    [_portraitView setImage:[UIImage imageNamed:model.audiencePortrait]];
    [_nameLbl setText:model.audienceName];
   
}

- (void)initializedSubViews {
    [self setBackgroundColor:[UIColor blackColor]];
    [self addSubview:self.portraitView];
    [_portraitView setFrame:CGRectMake(20, 10, 20, 20)];
    [_portraitView.layer setCornerRadius:10];
    [_portraitView.layer setMasksToBounds:YES];
    if (self.inviteBtn) {
        [self.inviteBtn removeFromSuperview];
        self.inviteBtn = nil;
    }
    self.inviteBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - 105, 5, 100, 30)];
    [self.inviteBtn setBackgroundColor:[UIColor blueColor]];
    [self.inviteBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [self.inviteBtn setTitle:@"邀请连麦" forState:UIControlStateNormal];
    [self.inviteBtn addTarget:self action:@selector(didSelectInviteBtn) forControlEvents:UIControlEventTouchUpInside];
    if (self.model.invited) {
        [self.inviteBtn setBackgroundColor:[UIColor lightGrayColor]];
        self.inviteBtn.enabled = NO;
    } else {
        [self.inviteBtn setBackgroundColor:[UIColor blueColor]];
        self.inviteBtn.enabled = YES;
    }
    [self addSubview:self.nameLbl];
    [self addSubview:self.inviteBtn];
    [_nameLbl setFrame:CGRectMake(20 + 20 + 10, 10, 100, 20)];
     _inviteBtn.frame = CGRectMake(self.contentView.frame.size.width - 105, 5, 100, 30);
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
        [_nameLbl setTextAlignment:NSTextAlignmentLeft];
        [_nameLbl setFont:[UIFont systemFontOfSize:18.0f]];
        [_nameLbl setNumberOfLines:1];
        [_nameLbl setTextColor:[UIColor whiteColor]];
    }
    return  _nameLbl;
}

- (void)didSelectInviteBtn{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectInviteAudienceBtn:)]) {
        [self.delegate didSelectInviteAudienceBtn:self.model];
    }
}
@end
