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
    
    [self addSubview:self.nameLbl];
    [_nameLbl setFrame:CGRectMake(20 + 20 + 10, 10, 100, 20)];
    
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

@end
