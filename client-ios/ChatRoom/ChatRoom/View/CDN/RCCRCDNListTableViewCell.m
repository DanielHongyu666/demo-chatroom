//
//  RCCRCDNListTableViewCell.m
//  ChatRoom
//
//  Created by 孙承秀 on 2020/5/25.
//  Copyright © 2020 罗骏. All rights reserved.
//

#import "RCCRCDNListTableViewCell.h"
#import "RCLabel.h"
#import "RCButton.h"
#import "Masonry.h"
@interface RCCRCDNListTableViewCell()

/**
 dic
 */
@property(nonatomic , strong)NSDictionary *dic;

/**
 cdn
 */
@property(nonatomic , strong)RCLabel *cdnLabel;

/**
 addbtn
 */
@property(nonatomic , strong)RCButton *addBtn;

/**
 remove btn
 */
@property(nonatomic , strong)RCButton *removeBtn;
@end
@implementation RCCRCDNListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}
-(void)configWithCdn:(NSDictionary *)cdn{
    self.dic = cdn;
    NSString *pushUrl = cdn[@"pushUrl"];
    [self addSubview:self.cdnLabel];
    [self addSubview:self.addBtn];
    [self addSubview:self.removeBtn];
    self.cdnLabel.text = pushUrl;
}
- (void)didClickAdd{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCopyCell:)]) {
        [self.delegate didCopyCell:self];
    }
}
- (void)didClickRemove{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDeleteCell:)]) {
        [self.delegate didDeleteCell:self];
    }
}
-(void)layoutSubviews{
    [super layoutSubviews];
    [self.removeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).mas_equalTo(-5);
        make.top.mas_equalTo(self.mas_top).mas_offset(25);
        make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-25);
        make.width.mas_equalTo(@(30));
    }];
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.removeBtn.mas_left).offset(-10);
        make.top.mas_equalTo(self.mas_top).mas_offset(25);
        make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-25);
        make.height.mas_equalTo(self.removeBtn);
        make.width.mas_equalTo(@(60));
    }];
    [_cdnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(5);
        make.right.mas_equalTo(self.addBtn.mas_left).offset(-5);
        make.top.mas_equalTo(self.addBtn.mas_top);
        make.bottom.mas_equalTo(self);
    }];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
-(RCLabel *)cdnLabel{
    if (!_cdnLabel) {
        _cdnLabel = [[RCLabel alloc] init];
        [_cdnLabel makeConfig:^(RCLabel *lab) {
            lab.titleFont([UIFont systemFontOfSize:12]).titleColor([UIColor blackColor]);
            lab.numberOfLines = 0;
        }];
    }
    return _cdnLabel;
}
-(RCButton *)addBtn{
    if (!_addBtn) {
        _addBtn = [[RCButton alloc] init];
        [_addBtn makeConfig:^(RCButton *btn) {
            btn.layer.borderWidth = 1;
            btn.layer.borderColor = [UIColor blackColor].CGColor;
            btn.titleText(@"复制拉流",UIControlStateNormal).addTarget(self,@selector(didClickAdd)).cornerRadiusNumber(4);
            btn.titleColor([UIColor blackColor],UIControlStateNormal);
            btn.titleFont([UIFont systemFontOfSize:13]);
        }];
    }
    return _addBtn;;
}
- (RCButton *)removeBtn{
    if (!_removeBtn) {
        _removeBtn = [[RCButton alloc] init];
        [_removeBtn makeConfig:^(RCButton *btn) {
            btn.layer.borderWidth = 1;
            btn.layer.borderColor = [UIColor blackColor].CGColor;
            btn.titleText(@"移除",UIControlStateNormal).addTarget(self,@selector(didClickRemove));
            btn.titleColor([UIColor blackColor],UIControlStateNormal).cornerRadiusNumber(4);
            btn.titleFont([UIFont systemFontOfSize:13]);
        }];
    }
    return _removeBtn;
}
@end
