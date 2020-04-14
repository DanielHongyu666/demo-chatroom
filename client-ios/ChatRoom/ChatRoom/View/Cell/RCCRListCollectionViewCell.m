//
//  RCCRListCollectionViewCell.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/9.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "RCCRListCollectionViewCell.h"

@interface RCCRListCollectionViewCell ()

@property (nonatomic, strong)UIImageView *icon;

@property (nonatomic, strong)UILabel *titleLabel;

@property (nonatomic, strong)UILabel *nameLabel;

@property (nonatomic, strong)UILabel *numberLabel;
@end

@implementation RCCRListCollectionViewCell


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setSubviews];
    }
    return self;
}

- (void)setSubviews {
    [self addSubview:self.icon];
    [self addSubview:self.titleLabel];
    [self addSubview:self.nameLabel];
    [self addSubview:self.numberLabel];
    CGSize size = self.bounds.size;
    [self.icon setFrame:CGRectMake(0, 0, size.width, size.height - 20)];
    [self.titleLabel setFrame:CGRectMake(size.width - 70, 10, 60, 20)];
    [self.titleLabel.layer setCornerRadius:10];
    [self.titleLabel.layer setMasksToBounds:YES];
    [self.nameLabel setFrame:CGRectMake(5, self.icon.frame.origin.y + self.icon.frame.size.height - 20 - 6, size.width - 10, 20)];
    [self.numberLabel setFrame:CGRectMake(size.width -  90, size.width - 20, 80, 20)];
}

- (void)setData:(RCCRLiveModel *)model {

    [self.titleLabel setText:@"直播中"];
    [self.nameLabel setText:model.hostName];
//    [self.numberLabel setText:[NSString stringWithFormat:@"%ld人",(long)model.audienceAmount]];
    NSString *imageName = [NSString stringWithFormat:@"chatroom_0%@",model.cover];
    [self.icon setImage:[UIImage imageNamed:imageName]];
}


- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        [_icon setUserInteractionEnabled:YES];
    }
    return _icon;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setNumberOfLines:0];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setFont:[UIFont systemFontOfSize:16]];
        _titleLabel.hidden = YES;
        [_titleLabel setBackgroundColor:[UIColor grayColor]];
    }
    return _titleLabel;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setNumberOfLines:0];
        [_nameLabel setTextAlignment:NSTextAlignmentCenter];
        [_nameLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:13]];
        [_nameLabel setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
        [_nameLabel setTextColor:[UIColor whiteColor]];
    }
    return _nameLabel;
}

- (UILabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc] init];
        [_numberLabel setNumberOfLines:0];
        [_numberLabel setTextAlignment:NSTextAlignmentRight];
        [_numberLabel setFont:[UIFont systemFontOfSize:16]];
    }
    return _numberLabel;
}

@end
