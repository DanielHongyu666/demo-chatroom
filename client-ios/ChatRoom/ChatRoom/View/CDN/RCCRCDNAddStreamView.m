//
//  RCCRCDNAddStreamView.m
//  ChatRoom
//
//  Created by 孙承秀 on 2020/5/25.
//  Copyright © 2020 罗骏. All rights reserved.
//

#import "RCCRCDNAddStreamView.h"
#import "Masonry.h"
#import "RCButton.h"
#import "RCLabel.h"
#import "RCCRCDNSelectViewController.h"
#import <RongRTCLib/RongRTCLib.h>
@interface RCCRCDNAddStreamView()<UITextFieldDelegate,RCCRSelectCDNProtocol>


/**
 select dic
 */
@property(nonatomic , strong)NSDictionary *selectDic;
/**
 close button
 */
@property(nonatomic , strong)RCButton *closeButton;

/**
 text field
 */
//@property(nonatomic , strong)UITextField *textField;

/**
 cdnBtn
 */
@property(nonatomic , strong)RCButton *cdnBtn;
@end

@implementation RCCRCDNAddStreamView

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews{
    // 关闭按钮
    self.closeButton = [[RCButton alloc] init];
    [self.closeButton makeConfig:^(RCButton *btn) {
        btn.titleFont([UIFont systemFontOfSize:15]).titleText(@"X",UIControlStateNormal).titleColor([UIColor blackColor],UIControlStateNormal);
        btn.addTarget(self,@selector(didClickCloseBtn));
        btn.cornerRadiusNumber(4);
    }];
    [self addSubview:self.closeButton];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(5);
        make.right.mas_equalTo(self.mas_right).offset(-5);
        make.width.mas_equalTo(@(20));
        make.height.mas_equalTo(@(20));
    }];
    
    // 旁路推流接口测试
    RCLabel *titleLabel = [[RCLabel alloc] init];
    [titleLabel makeConfig:^(RCLabel *lab) {
        lab.titleFont([UIFont boldSystemFontOfSize:20]).labelText(@"旁路推流接口测试");
    }];
    [self addSubview: titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.closeButton.mas_bottom).offset(5);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    
    
    RCLabel *pushLabel = [[RCLabel alloc] init];
    [pushLabel makeConfig:^(RCLabel *lab) {
        lab.titleFont([UIFont systemFontOfSize:15]).labelText(@"推 CDN 地址");
        //        lab.backgroundColor = [UIColor purpleColor];
    }];
    [self addSubview: pushLabel];
    [pushLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(20);
        make.left.mas_equalTo(self.mas_left).offset(10);
        make.width.mas_equalTo(@(100));
    }];
    
    RCButton *add = [[RCButton alloc] init];
    [add makeConfig:^(RCButton *btn) {
        btn.addTarget(self,@selector(didClickAdd));
        btn.titleText(@"添加",UIControlStateNormal).titleColor([UIColor blackColor],UIControlStateNormal).cornerRadiusNumber(4);
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = [UIColor blackColor].CGColor;
    }];
    [self addSubview:add];
    
    [add mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-10);
        make.top.mas_equalTo(pushLabel.mas_top);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
    }];
    
//    UITextField *textField = [[UITextField alloc] init];
//    [textField setPlaceholder:@"请输入 cdn 地址"];
//    textField.layer.borderWidth = 1;
//    textField.layer.borderColor = [UIColor blackColor].CGColor;
//    textField.layer.cornerRadius = 4;
//    textField.layer.masksToBounds = YES;
//    textField.delegate = self;
//    self.textField = textField;
//    [self addSubview:textField];
    
    self.cdnBtn = [[RCButton alloc] init];
    [self.cdnBtn makeConfig:^(RCButton *btn) {
        btn.addTarget(self,@selector(didClickCDNBtn));
        NSString *text = btn.currentTitle ? btn.currentTitle : @"选择 CDN 地址";
        btn.titleText(text,UIControlStateNormal).titleColor([UIColor blackColor],UIControlStateNormal).cornerRadiusNumber(4);
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = [UIColor blackColor].CGColor;
    }];
    [self addSubview:self.cdnBtn];
    [self.cdnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(pushLabel.mas_right).offset(5);
        make.right.mas_equalTo(add.mas_left).offset(-5);
        make.top.mas_equalTo(pushLabel.mas_top);
    }];
    
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
}
- (void)didClickAdd{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didAddCDNAddress:)]) {
        [self.delegate didAddCDNAddress:self.selectDic];
    }
}
- (void)didClickCDNBtn{
    RCCRCDNSelectViewController *vc = [[RCCRCDNSelectViewController alloc] init];
    vc.delegate = self;
    RCCRCDNSelectModel *model = [[RCCRCDNSelectModel alloc] init];
    model.roomId = [RCRTCEngine sharedInstance].currentRoom.roomId;
    model.streamName = [RCRTCEngine sharedInstance].currentRoom.sessionId;
    model.appName = @"sealLive";
    vc.model = model;
    UIViewController *root = [self viewController];
    [root presentViewController:vc animated:YES completion:nil];
}
-(void)didSelectCDN:(NSArray *)list{
    NSDictionary *dic = list.firstObject;
    self.selectDic = dic;
    self.cdnBtn.titleLabel.text = self.selectDic[@"pushUrl"];
}
-(UIViewController*)viewController{
    UIResponder *nextResponder =  self;
    do{
    nextResponder = [nextResponder nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
            return (UIViewController*)nextResponder;
    } while (nextResponder != nil);
    return nil;
}

- (void)didClickCloseBtn{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickClose)]) {
        [self.delegate didClickClose];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
