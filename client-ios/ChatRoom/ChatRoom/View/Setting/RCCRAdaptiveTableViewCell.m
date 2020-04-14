//
//  RCCRAdaptiveTableViewCell.m
//  ChatRoom
//
//  Created by 孙承秀 on 2019/12/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCCRAdaptiveTableViewCell.h"
#import "RCLabel.h"
#import "RCButton.h"
#import "UIColor+Helper.h"
#import "RCImageView.h"
@interface RCCRAdaptiveTableViewCell()<UITextFieldDelegate>

/**
 detail label
 */
@property(nonatomic , strong)RCLabel *titleLabel;

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
@implementation RCCRAdaptiveTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)product:(RCCRSettingModel *)model{
    [super product:model];
    if (!self.layoutModel) {
        self.layoutModel = [[RCCRLiveLayoutModel alloc] initWithType:RCCRLiveLayoutTypeAdaptive];
    }
    
    [self removeSupviews];
    
    self.viewCropLabel = [[RCLabel alloc] init];
    [self.viewCropLabel makeConfig:^(RCLabel *lab) {
        lab.titleFont([UIFont fontWithName:@"PingFangSC-Regular" size:14]).labelText(@"画面裁剪");
    }];
     [self addSubview:self.viewCropLabel ];
    self.switchBtn = [[UISwitch alloc] init];
    self.switchBtn.onTintColor = [UIColor colorWithHexString:@"0x0099FF" alpha:1.0];
    self.switchBtn.on = self.layoutModel.adaptiveCrop;
    [self.switchBtn addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
   
    [self addSubview:self.switchBtn];
    NSArray *arr = @[@"主播+ 1个连麦者",@"主播+ 2 个连麦者",@"主播+ 3 个连麦者",@"主播+ 4个连麦者",@"主播+ 5 个连麦者",@"主播+ 6 个连麦者"];
    int width = 111;
    int height = 20;
    for (NSInteger i = 0; i < arr.count; i ++) {
        NSString *text = arr[i];
        RCLabel *label = [[RCLabel alloc] initWithFrame:CGRectMake(15 + (width + 10) * (i % 3),self.switchBtn.frame.origin.y + self.switchBtn.frame.size.height  + 20 + (height + 74) * (i / 3), width, height)];
        [label makeConfig:^(RCLabel *lab) {
            lab.titleFont([UIFont fontWithName:@"PingFangSC-Regular" size:14]).labelText(text);
        }];
        [self addSubview:label];
        
    }
    NSArray *images = @[@"1",@"2",@"3",@"4",@"5",@"6"];
    int iwidth = 100;
    int iheight = 60;
    for (NSInteger i = 0; i < images.count; i ++) {
        NSString *name = images[i];
        RCImageView *imageView = [[RCImageView alloc] initWithFrame:CGRectMake(17 + (iwidth + 17) * (i % 3), self.switchBtn.frame.origin.y + self.switchBtn.frame.size.height  + 44 + (iheight + 34) * (i / 3), iwidth, iheight)];
        [imageView setImage:[UIImage imageNamed:name]];
        [self addSubview:imageView];
        
    }
    self.titleLabel = [[RCLabel alloc] init];
    [self.titleLabel makeConfig:^(RCLabel *lab) {
        lab.titleFont([UIFont fontWithName:@"PingFangSC-Regular" size:14]).labelText(@"注：该设置只影响观众端看到的直播样式，H 表示主播，M 表示连麦者").numberLines(0);
        lab.titleColor([UIColor colorWithHexString:@"0x999999" alpha:1.0]);
    }];
    [self addSubview:self.titleLabel];
    self.saveBtn = [[RCButton alloc] init];
    [self.saveBtn makeConfig:^(RCButton *btn) {
        btn.titleFont([UIFont fontWithName:@"PingFangSC-Regular" size:14]).backColor([UIColor colorWithHexString:@"0099FF" alpha:1.0]).titleText(@"保存",UIControlStateNormal);
        btn.addTarget(self,@selector(didClickSaveBtn:));
    }];
    [self addSubview:self.saveBtn];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    self.viewCropLabel.frame = CGRectMake(15, 0, 56, 20);
    self.switchBtn.frame = CGRectMake(self.viewCropLabel.frame.origin.x + self.viewCropLabel.frame.size.width + 22, self.viewCropLabel.frame.origin.y, 44, 22);
    self.titleLabel.frame = CGRectMake(15, 208 + self.switchBtn.frame.origin.y + self.switchBtn.frame.size.height , 344 , 45);
    self.saveBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 100) / 2, self.frame.size.height - 30 - 30, 100, 32);
}
- (void)changeValue:(UISwitch *)swi{
    self.layoutModel.adaptiveCrop = swi.on;
}
- (void)didClickSaveBtn:(UIButton *)btn{
    self.layoutModel.layoutType = RCCRLiveLayoutTypeAdaptive;
    if (self.returnDelegate && [self.returnDelegate respondsToSelector:@selector(didClickedCell:layout:)]) {
        [self.returnDelegate didClickedCell:self layout:self.layoutModel];
    }
}
- (void)removeSupviews{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[RCLabel class]]) {
            [view removeFromSuperview];
        }
    }
    if (self.titleLabel) {
        [self.titleLabel removeFromSuperview];
    }
    if (self.switchBtn) {
        [self.switchBtn removeFromSuperview];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
