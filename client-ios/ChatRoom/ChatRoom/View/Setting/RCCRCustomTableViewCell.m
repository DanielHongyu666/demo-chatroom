//
//  RCCRCustomTableViewCell.m
//  ChatRoom
//
//  Created by 孙承秀 on 2019/12/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCCRCustomTableViewCell.h"
#import "RCLabel.h"
#import "RCButton.h"
#import "UIColor+Helper.h"
#import "RCImageView.h"
#define MAXHEIGHT (640 / 6)
#define MINHEIGHT 0
#define FAC (3.0/4.0)
#define MAXW 480
@interface RCCRCustomTableViewCell()<UITextFieldDelegate>
/**
 viewCropLabel
 */
@property(nonatomic , strong)RCLabel *viewCropLabel;

/**
 switch
 */
@property(nonatomic , strong)UISwitch *switchBtn;

/**
 M1XY
 */
@property(nonatomic , strong)RCLabel *M1XY;

/**
 x label
 */
@property(nonatomic , strong)RCLabel *xLabel;

/**
 y label
 */
@property(nonatomic , strong)RCLabel *yLabel;

/**
 x textField
 */
@property(nonatomic , strong)UITextField *xTextField;

/**
 y textField
 */
@property(nonatomic , strong)UITextField *yTextField;

/**
 detail
 */
@property(nonatomic , strong)RCLabel *detail1Label;

/**
 M1WH
 */
@property(nonatomic , strong)RCLabel *M1WH;

/**
 x label
 */
@property(nonatomic , strong)RCLabel *wLabel;

/**
 y label
 */
@property(nonatomic , strong)RCLabel *hLabel;

/**
 x textField
 */
@property(nonatomic , strong)UITextField *wTextField;

/**
 y textField
 */
@property(nonatomic , strong)UITextField *hTextField;

/**
 detail2
 */
@property(nonatomic , strong)RCLabel *detail2Label;

/**
 title label
 */
@property(nonatomic , strong)RCLabel *titleLabel;

/**
 imageView
 */
@property(nonatomic , strong)RCImageView *detailImageView;

/**
 detail 3
 */
@property(nonatomic , strong)RCLabel *detail3Label;

/**
 save btn
 */
@property(nonatomic , strong)RCButton *saveBtn;
@end
@implementation RCCRCustomTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)product:(RCCRSettingModel *)model{
    [super product:model];
    if (!self.layoutModel) {
        [self setDefaultModel];
    }
    
    [self removeSubviews];
    
    
    self.viewCropLabel = [[RCLabel alloc] initWithFrame:CGRectMake(15, 0, 56, 20)];
    [self.viewCropLabel makeConfig:^(RCLabel *lab) {
        lab.titleFont([UIFont fontWithName:@"PingFangSC-Regular" size:14]).labelText(@"画面裁剪");
    }];
    
    
    self.switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(self.viewCropLabel.frame.origin.x + self.viewCropLabel.frame.size.width + 22, self.viewCropLabel.frame.origin.y, 44, 22)];
    self.switchBtn.onTintColor = [UIColor colorWithHexString:@"0x0099FF" alpha:1.0];
    self.switchBtn.on = self.layoutModel.customCrop;
    [self.switchBtn addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
    
    self.M1XY = [[RCLabel alloc] initWithFrame:CGRectMake(self.viewCropLabel.frame.origin.x, self.switchBtn.frame.origin.y + self.switchBtn.frame.size.height + 22, 98, 20)];
    [self.M1XY makeConfig:^(RCLabel *lab) {
        lab.titleFont([UIFont fontWithName:@"PingFangSC-Regular" size:14]).labelText(@"连麦者(M1)坐标");
    }];
    
    self.xLabel = [[RCLabel alloc] initWithFrame:CGRectMake(self.M1XY.frame.origin.x + self.M1XY.frame.size.width + 19, self.M1XY.frame.origin.y, 9, 20)];
    [self.xLabel makeConfig:^(RCLabel *lab) {
        lab.titleFont([UIFont fontWithName:@"PingFangSC-Regular" size:14]).labelText(@"X");
    }];
    
    
    self.xTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.xLabel.frame.origin.x + self.xLabel.frame.size.width + 6, self.switchBtn.frame.origin.y + self.switchBtn.frame.size.height + 20, 50, 24)];
    self.xTextField.layer.borderWidth = 1;
    self.xTextField.layer.borderColor = [UIColor colorWithHexString:@"0x979797" alpha:1.0].CGColor;
    self.xTextField.tag = 10;
    self.xTextField.delegate = self;
    [self.xTextField addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventEditingChanged];
    self.xTextField.textAlignment = NSTextAlignmentCenter;
    if (self.layoutModel.x > 0) {
        self.xTextField.text = [NSString stringWithFormat:@"%.0f",self.layoutModel.x];
    }
    
    
    self.yLabel = [[RCLabel alloc] initWithFrame:CGRectMake(self.xTextField.frame.origin.x + self.xTextField.frame.size.width + 19, self.M1XY.frame.origin.y, 9, 20)];
    [self.yLabel makeConfig:^(RCLabel *lab) {
        lab.titleFont([UIFont fontWithName:@"PingFangSC-Regular" size:14]).labelText(@"Y");
    }];
    
    
    self.yTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.yLabel.frame.origin.x + self.yLabel.frame.size.width + 6, self.switchBtn.frame.origin.y + self.switchBtn.frame.size.height + 20, 50, 24)];
    //    self.yTextField.layer.borderWidth = 1;
    //    self.yTextField.layer.borderColor = [UIColor colorWithHexString:@"0x979797" alpha:1.0].CGColor;
    self.yTextField.text = @"0";
    self.yTextField.textAlignment = NSTextAlignmentCenter;
    self.yTextField.enabled = NO;
    
    
    self.detail1Label = [[RCLabel alloc] initWithFrame:CGRectMake(self.M1XY.frame.origin.x, self.M1XY.frame.origin.y + self.M1XY.frame.size.height + 6, 255, 21)];
    [self.detail1Label makeConfig:^(RCLabel *lab) {
        lab.titleFont([UIFont fontWithName:@"PingFangSC-Regular" size:14]).labelText(@"其他连麦者坐标由系统根据高度自动计算").numberLines(1).titleColor([UIColor colorWithHexString:@"0x999999" alpha:1.0]);
    }];
    
    
    self.M1WH = [[RCLabel alloc] initWithFrame:CGRectMake(self.viewCropLabel.frame.origin.x, self.detail1Label.frame.origin.y + self.detail1Label.frame.size.height + 20, 98, 20)];
    [self.M1WH makeConfig:^(RCLabel *lab) {
        lab.titleFont([UIFont fontWithName:@"PingFangSC-Regular" size:14]).labelText(@"连麦者(M1)坐标");
    }];
    
    self.wLabel = [[RCLabel alloc] initWithFrame:CGRectMake(self.M1WH.frame.origin.x + self.M1WH.frame.size.width + 19, self.M1WH.frame.origin.y, 14, 20)];
    [self.wLabel makeConfig:^(RCLabel *lab) {
        lab.titleFont([UIFont fontWithName:@"PingFangSC-Regular" size:14]).labelText(@"宽");
    }];
    
    
    self.wTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.wLabel.frame.origin.x + self.wLabel.frame.size.width + 6, self.detail1Label.frame.origin.y + self.detail1Label.frame.size.height + 18, 50, 24)];
//    self.wTextField.layer.borderWidth = 1;
//    self.wTextField.layer.borderColor = [UIColor colorWithHexString:@"0x979797" alpha:1.0].CGColor;
    self.wTextField.tag = 20;
    self.wTextField.delegate = self;
    self.wTextField.enabled = NO;
    self.wTextField.textAlignment = NSTextAlignmentCenter;
    self.wTextField.text = @"0";
    self.wTextField.textAlignment = NSTextAlignmentCenter;
    if (self.layoutModel.width > 0) {
        self.wTextField.text = [NSString stringWithFormat:@"%.0f",self.layoutModel.width];
    }
    
    self.hLabel = [[RCLabel alloc] initWithFrame:CGRectMake(self.wTextField.frame.origin.x + self.wTextField.frame.size.width + 19, self.M1WH.frame.origin.y, 14, 20)];
    [self.hLabel makeConfig:^(RCLabel *lab) {
        lab.titleFont([UIFont fontWithName:@"PingFangSC-Regular" size:14]).labelText(@"高");
    }];
    
    
    self.hTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.hLabel.frame.origin.x + self.hLabel.frame.size.width + 6, self.wTextField.frame.origin.y, 50, 24)];
    self.hTextField.layer.borderWidth = 1;
    self.hTextField.layer.borderColor = [UIColor colorWithHexString:@"0x979797" alpha:1.0].CGColor;
    self.hTextField.tag = 30;
    self.hTextField.textAlignment = NSTextAlignmentCenter;
    self.hTextField.delegate = self;
    if (self.layoutModel.height > 0) {
        self.hTextField.text = [NSString stringWithFormat:@"%.0f",self.layoutModel.height];
    } else {
        self.hTextField.text = [NSString stringWithFormat:@"%d",MAXHEIGHT];
        NSLog(@"%@",self.hTextField.text);
        [self valueChange:self.hTextField];
        self.xTextField.text = [NSString stringWithFormat:@"%.0f",MAXW - self.layoutModel.width];
        [self valueChange:self.xTextField];
    }
    [self.hTextField addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventEditingChanged];
    
    
    self.detail2Label = [[RCLabel alloc] initWithFrame:CGRectMake(self.M1WH.frame.origin.x, self.M1WH.frame.origin.y + self.M1WH.frame.size.height + 6, 255, 21)];
    [self.detail2Label makeConfig:^(RCLabel *lab) {
        lab.titleFont([UIFont fontWithName:@"PingFangSC-Regular" size:14]).labelText(@"该画面尺寸适用于所有的连麦者").numberLines(1).titleColor([UIColor colorWithHexString:@"0x999999" alpha:1.0]);
    }];
    
    self.titleLabel = [[RCLabel alloc] initWithFrame:CGRectMake(self.detail2Label.frame.origin.x, self.detail2Label.frame.origin.y + self.detail2Label.frame.size.height + 10, 196, 20)];
    [self.titleLabel makeConfig:^(RCLabel *lab) {
        lab.titleFont([UIFont fontWithName:@"PingFangSC-Regular" size:14]).labelText(@"按照连麦顺序，在下述位置显示");
    }];
    
    self.detailImageView = [[RCImageView alloc] initWithFrame:CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 2, 100, 83)];
    [self.detailImageView setImage:[UIImage imageNamed:@"8"]];
    
    
    self.detail3Label = [[RCLabel alloc] initWithFrame:CGRectMake(self.detailImageView.frame.origin.x, self.detailImageView.frame.origin.y + self.detailImageView.frame.size.height + 11, 330, 45)];
    [self.detail3Label makeConfig:^(RCLabel *lab) {
        lab.titleFont([UIFont fontWithName:@"PingFangSC-Regular" size:14]).titleColor([UIColor colorWithHexString:@"0x999999" alpha:1.0]).labelText(@"注：该设置仅影响观众端看到的直播样式，H 表示主播，M 表示连麦者").numberLines(0);
    }];
    
    self.saveBtn = [[RCButton alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 100) / 2, self.detail3Label.frame.origin.y + self.detail3Label.frame.size.height + 17, 100, 32)];
    [self.saveBtn makeConfig:^(RCButton *btn) {
        btn.titleFont([UIFont fontWithName:@"PingFangSC-Regular" size:14]).titleColor([UIColor colorWithHexString:@"0xFFFFFF" alpha:1.0],UIControlStateNormal).backColor([UIColor colorWithHexString:@"0x0099FF" alpha:1.0]).titleText(@"保存",UIControlStateNormal).cornerRadiusNumber(2);
        btn.addTarget(self,@selector(didClickSaveBtn:));
    }];
    [self addSubview:self.switchBtn];
    [self addSubview:self.viewCropLabel];
    [self addSubview:self.M1XY];
    [self addSubview:self.xLabel];
    [self addSubview:self.yLabel];
    [self addSubview:self.xTextField];
    [self addSubview:self.yTextField];
    [self addSubview:self.detail1Label];
    [self addSubview:self.M1WH];
    [self addSubview:self.wLabel];
    [self addSubview:self.hLabel];
    [self addSubview:self.wTextField];
    [self addSubview:self.hTextField];
    [self addSubview: self.detail2Label];
    [self addSubview:self.titleLabel];
    [self addSubview:self.detailImageView];
    [self addSubview:self.detail3Label];
    [self addSubview:self.saveBtn];
    
    
}
- (void)setDefaultModel{
    self.layoutModel = [[RCCRLiveLayoutModel alloc] initWithType:RCCRLiveLayoutTypeCustom];
    self.layoutModel.customCrop = NO;
    
}
- (void)didClickSaveBtn:(UIButton *)btn{
    self.layoutModel.layoutType = RCCRLiveLayoutTypeCustom;
   if (self.returnDelegate && [self.returnDelegate respondsToSelector:@selector(didClickedCell:layout:)]) {
        [self.returnDelegate didClickedCell:self layout:self.layoutModel];
    }
}
- (void)removeSubviews{
    if (self.viewCropLabel) {
        [self.viewCropLabel removeFromSuperview];
    }
    if (self.switchBtn) {
        [self.switchBtn removeFromSuperview];
    }
    if (self.M1XY) {
        [self.M1XY removeFromSuperview];
    }
    if (self.xLabel) {
        [self.xLabel removeFromSuperview];
    }
    if (self.yLabel) {
        [self.yLabel removeFromSuperview];
    }
    if (self.xTextField) {
        [self.xTextField removeFromSuperview];
    }
    if (self.yTextField) {
        [self.yTextField removeFromSuperview];
    }
    if (self.detail1Label) {
        [self.detail1Label removeFromSuperview];
    }
    if (self.M1WH) {
        [self.M1WH removeFromSuperview];
    }
    if (self.wLabel) {
        [self.wLabel removeFromSuperview];
    }
    if (self.hLabel) {
        [self.hLabel removeFromSuperview];
    }
    if (self.wTextField ) {
        [self.wTextField removeFromSuperview];
    }
    if (self.hTextField) {
        [self.hTextField removeFromSuperview];
    }
    if (self.detail2Label) {
        [self.detail2Label removeFromSuperview];
    }
    if (self.titleLabel) {
        [self.titleLabel removeFromSuperview];
    }
    if (self.detailImageView) {
        [self.detailImageView removeFromSuperview];
    }
    if (self.detail3Label) {
        [self.detail3Label removeFromSuperview];
    }
    if (self.saveBtn) {
        [self.saveBtn removeFromSuperview];
    }
}
- (void)valueChange:(UITextField *)textField{
    int num = [textField.text intValue];
    if (textField.tag == 30) {
        CGFloat widht = ceil(num * (FAC)) ;
        self.wTextField.text = [NSString stringWithFormat:@"%.0f",widht];
        self.layoutModel.width = [self.wTextField.text intValue];
        self.layoutModel.height  = [self.hTextField.text intValue];
        self.xTextField.text = [NSString stringWithFormat:@"%.0f",MAXW - self.layoutModel.width];
        self.layoutModel.x = [self.xTextField.text intValue];
    }
    if (textField.tag == 10) {
        self.layoutModel.x = [textField.text intValue];
    }
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    BOOL res = YES;
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i= 0;
    while (i < string.length) {
        NSString *str = [string substringWithRange:NSMakeRange(i, 1)];
        NSRange r = [str rangeOfCharacterFromSet:set];
        if (r.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    NSLog(@"%@------%@",textField.text , string);
    NSString *numStr = [textField.text stringByAppendingString:string];
    int num = [numStr intValue];
    if (res) {
        if (textField.tag == 10) {
            if (num <0 || num > MAXW) {
                res = NO;
            }
        }
        if (textField.tag == 30) {
            if (num < MINHEIGHT || num > MAXHEIGHT) {
                res = NO;
            }
        }
    }
    if (res && textField.tag == 30) {
        
    }
    return res;
}

- (void)changeValue:(UISwitch *)swi{
    self.layoutModel.customCrop = swi.on;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
