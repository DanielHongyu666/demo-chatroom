//
//  RCCRSuspensionTableViewCell.m
//  ChatRoom
//
//  Created by 孙承秀 on 2019/12/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCCRSuspensionTableViewCell.h"
#import "RCLabel.h"
#import "RCImageView.h"
#import "UIColor+Helper.h"
#import "RCButton.h"
@interface RCCRSuspensionTableViewCell()

/**
 detail
 */
@property(nonatomic , strong)RCLabel *detail1Label;

/**
 titleLabel
 */
@property(nonatomic , strong)RCLabel *titleLabel;

/**
 imageview
 */
@property(nonatomic , strong)RCImageView *detailImageView;

/**
 detail2
 */
@property(nonatomic , strong)RCLabel *detail2Label;
/**
 save btn
 */
@property(nonatomic , strong)RCButton *saveBtn;
/**
 switch
 */
@property(nonatomic , strong)UISwitch *switchBtn;

/**
 viewCropLabel
 */
@property(nonatomic , strong)RCLabel *viewCropLabel;
@end
@implementation RCCRSuspensionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)product:(RCCRSettingModel *)model{
    
    [super product:model];
    if (!self.layoutModel) {
        self.layoutModel = [[RCCRLiveLayoutModel alloc] initWithType:RCCRLiveLayoutTypeSuspension];
    }
    
    [self removeSubviews];
    
    self.viewCropLabel = [[RCLabel alloc] init];
    [self.viewCropLabel makeConfig:^(RCLabel *lab) {
        lab.titleFont([UIFont fontWithName:@"PingFangSC-Regular" size:14]).labelText(@"画面裁剪");
    }];
    [self addSubview:self.viewCropLabel ];
    self.switchBtn = [[UISwitch alloc] init];
    self.switchBtn.onTintColor = [UIColor colorWithHexString:@"0x0099FF" alpha:1.0];
    self.switchBtn.on = self.layoutModel.suspensionCrop;
    [self.switchBtn addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.switchBtn];
    self.detail1Label = [[RCLabel alloc] init];
    [self.detail1Label makeConfig:^(RCLabel *lab) {
        lab.titleFont([UIFont fontWithName:@"PingFangSC-Regular" size:14]).labelText(@"按照连麦顺序，在下述位置显示");
    }];
    [self addSubview: self.detail1Label];
    
    self.titleLabel = [[RCLabel alloc] init];
    [self.titleLabel makeConfig:^(RCLabel *lab) {
        lab.titleFont([UIFont fontWithName:@"PingFangSC-Regular" size:14]).labelText(@"主播 + 6 个连麦者");
    }];
    [self addSubview:self.titleLabel];
    
    self.detailImageView = [[RCImageView alloc] init];
    [self.detailImageView setImage:[UIImage imageNamed:@"7"]];
    [self addSubview:self.detailImageView];
    
    self.detail2Label = [[RCLabel alloc] init];
    [self.detail2Label makeConfig:^(RCLabel *lab) {
        lab.titleFont([UIFont fontWithName:@"PingFangSC-Regular" size:14]).titleColor([UIColor colorWithHexString:@"0x999999" alpha:1.0]);
        lab.numberLines(0).labelText(@"注：该设置仅影响关注端看到的直播样式，H 表示主播，M 表示连麦者");
    }];
    [self addSubview:self.detail2Label];
    
    self.saveBtn = [[RCButton alloc] init];
    [self.saveBtn makeConfig:^(RCButton *btn) {
        btn.titleFont([UIFont fontWithName:@"PingFangSC-Regular" size:14]).titleColor([UIColor colorWithHexString:@"0xFFFFFF" alpha:1.0],UIControlStateNormal).backColor([UIColor colorWithHexString:@"0x0099FF" alpha:1.0]).titleText(@"保存",UIControlStateNormal).cornerRadiusNumber(2);
        btn.addTarget(self,@selector(didClickSaveBtn:));
    }];
    [self addSubview:self.saveBtn];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    self.viewCropLabel.frame = CGRectMake(15, 0, 56, 20);
    self.switchBtn.frame = CGRectMake(self.viewCropLabel.frame.origin.x + self.viewCropLabel.frame.size.width + 22, self.viewCropLabel.frame.origin.y, 44, 22);
    self.detail1Label.frame = CGRectMake(15, 20+ self.switchBtn.frame.origin.y + self.switchBtn.frame.size.height, 196, 20);
    self.titleLabel.frame = CGRectMake(self.detail1Label.frame.origin.x, self.detail1Label.frame.origin.y + self.detail1Label.frame.size.height + 10, 150, 20);
    self.detailImageView.frame = CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 4, 100, 80);
    self.detail2Label.frame = CGRectMake(self.detailImageView.frame.origin.x, self.detailImageView.frame.size.height + self.detailImageView.frame.origin.y + 10, 345, 45);
    self.saveBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 100) / 2, self.frame.size.height - 30 - 30, 100, 32);
}
- (void)changeValue:(UISwitch *)swi{
    self.layoutModel.suspensionCrop = swi.on;
}
- (void)removeSubviews{
    if (self.detail1Label) {
        [self.detail1Label removeFromSuperview];
    }
    if (self.switchBtn) {
        [self.switchBtn removeFromSuperview];
    }
    if (self.titleLabel) {
        [self.titleLabel removeFromSuperview];
    }
    if (self.detailImageView) {
        [self.detailImageView removeFromSuperview];
    }
    if (self.detail2Label) {
        [self.detail2Label removeFromSuperview];
    }
    if (self.saveBtn) {
        [self.saveBtn removeFromSuperview];
    }
}
- (void)didClickSaveBtn:(UIButton *)btn{
    self.layoutModel.layoutType = RCCRLiveLayoutTypeSuspension;
    if (self.returnDelegate && [self.returnDelegate respondsToSelector:@selector(didClickedCell:layout:)]) {
        [self.returnDelegate didClickedCell:self layout:self.layoutModel];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
