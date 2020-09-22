//
//  RCCRLiveViewController.m
//  ChatRoom
//
//  Created by 孙承秀 on 2019/9/4.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCCRLiveViewController.h"
#import "RCCRRongCloudIMManager.h"
#import "RCCRRongCloudIMManager.h"
#import "RCActiveWheel.h"
#import "RCCRManager.h"
#import "RCCRSettingViewController.h"
#import "RCCRLiveHttpManager.h"
@interface RCCRLiveViewController ()<UITextFieldDelegate>

/**
 imageview
 */
@property(nonatomic , strong)UIImageView *imageView;

/**
 title
 */
@property(nonatomic , strong)UILabel *titleLabel;

/**
 live room name
 */
@property(nonatomic , strong)UITextField *liveRoomTextfield;

/**
 name
 */
@property(nonatomic , strong)UITextField *nameTextField;

/**
 begin live btn
 */
@property(nonatomic , strong)UIButton *liveBtn;

/**
 error label
 */
@property(nonatomic , strong)UILabel *errorLabel;

/**
 live model
 */
@property(nonatomic , strong)RCCRLiveModel *model;
@end

@implementation RCCRLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 用于弹框测试
    [RCCRLiveHttpManager sharedManager].chatVC = self;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"创建直播间";
    RCCRLiveModel *model = [[RCCRLiveModel alloc] init];
    model.hostName = self.nameTextField.text;
    model.hostPortrait = [NSString stringWithFormat:@"%d",arc4random() % 5 + 1];
    model.audienceAmount = 0;
    model.fansAmount = 0;
    model.giftAmount = 0;
    model.praiseAmount = 0;
    model.attentionAmount = 0;
    model.liveMode = RCCRLiveModeHost;
    model.cover = model.hostPortrait;
    model.pubUserId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
    self.model = model;
    [self addSubviews];
    [self.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"chatroom_0%@",self.model.hostPortrait]]];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.nameTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.liveRoomTextfield];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)addSubviews{
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.liveRoomTextfield];

    [self.view addSubview:self.nameTextField];
    
    [self.view addSubview:self.liveBtn];
    [self.view addSubview:self.errorLabel];
    RCUserInfo *userinfo = [RCIMClient sharedRCIMClient].currentUserInfo;
    if (userinfo.name && userinfo.name.length > 0) {
        self.nameTextField.text = userinfo.name;
    }
}
-(UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 172, 172)];
        _imageView.backgroundColor = [UIColor redColor];
        _imageView.layer.cornerRadius = 4;
        _imageView.layer.masksToBounds = YES;
    }
    return _imageView;
}
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.imageView.frame.origin.x + self.imageView.frame.size.width + 10, self.imageView.frame.origin.y + 20, self.view.frame.size.width - (self.imageView.frame.origin.x + self.imageView.frame.size.width + 10) - 10, 40)];
        [_titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:14]];
        _titleLabel.numberOfLines = 0;
        [_titleLabel setText:@"请输入直播间名称，即可作为主播进入该直播间"];
    }
    return _titleLabel;
}
-(UITextField *)liveRoomTextfield{
    if (!_liveRoomTextfield) {
        _liveRoomTextfield = [[UITextField alloc] initWithFrame:CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y + self.imageView.frame.size.height + 10, self.view.frame.size.width - 20, 40)];
        _liveRoomTextfield.font = [UIFont systemFontOfSize:18];
        _liveRoomTextfield.textColor = [UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0];
        _liveRoomTextfield.textAlignment = NSTextAlignmentLeft;
        _liveRoomTextfield.keyboardType =UIKeyboardTypeDefault;
        _liveRoomTextfield.returnKeyType = UIReturnKeyDone;
        _liveRoomTextfield.borderStyle = UITextBorderStyleRoundedRect;
        _liveRoomTextfield.placeholder = @"请输入直播间名称（1-20个字符）";
        _liveRoomTextfield.delegate = self;
        //        _liveRoomTextfield.layer.borderWidth = 1;
        //        _liveRoomTextfield.layer.borderColor = [UIColor blackColor].CGColor;
        _liveRoomTextfield.layer.cornerRadius = 4;
        _liveRoomTextfield.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];;
        
    }
    return _liveRoomTextfield;
}
-(UITextField *)nameTextField{
    if (!_nameTextField) {
        _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.liveRoomTextfield.frame.origin.x, self.liveRoomTextfield.frame.origin.y + self.liveRoomTextfield.frame.size.height + 10, self.liveRoomTextfield.frame.size.width, self.liveRoomTextfield.frame.size.height)];
        _nameTextField.font = [UIFont systemFontOfSize:18];
        _nameTextField.textColor = [UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0];
        _nameTextField.textAlignment = NSTextAlignmentLeft;
        _nameTextField.keyboardType = UIKeyboardTypeDefault;
        _nameTextField.returnKeyType = UIReturnKeyDone;
        _nameTextField.borderStyle = UITextBorderStyleRoundedRect;
        _nameTextField.placeholder = @"请输入主播名称（1-10个字符）";
        _nameTextField.delegate = self;
//        _nameTextField.layer.borderWidth = 1;
//        _nameTextField.layer.borderColor = [UIColor blackColor].CGColor;
        _nameTextField.layer.cornerRadius = 4;
        _nameTextField.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];;
    }
    return _nameTextField;
}
-(UIButton *)liveBtn{
    if (!_liveBtn) {
        _liveBtn = [[UIButton alloc] init];
        CGRect frame = CGRectZero;
        frame = CGRectMake(self.liveRoomTextfield.frame.origin.x , self.nameTextField.frame.origin.y + self.nameTextField.frame.size.height+ 10+ self.errorLabel.frame.size.height+10, self.liveRoomTextfield.frame.size.width, 40);
        _liveBtn.frame = frame;
        [_liveBtn setTitle:@"开始直播" forState:UIControlStateNormal];
        [_liveBtn setBackgroundColor:[UIColor blueColor]];
        [_liveBtn setTintColor:[UIColor blackColor]];
        [_liveBtn addTarget:self action:@selector(joinAndLive) forControlEvents:UIControlEventTouchUpInside];
        _liveBtn.layer.cornerRadius = 4;
        _liveBtn.layer.masksToBounds = YES;
    }
    return _liveBtn;
}
-(UILabel *)errorLabel{
    if (!_errorLabel) {
        _errorLabel = [[UILabel alloc] init];
        CGRect frame = CGRectZero;
  
        frame = CGRectMake(self.liveRoomTextfield.frame.origin.x , self.nameTextField.frame.origin.y + self.nameTextField.frame.size.height+ 10, self.liveRoomTextfield.frame.size.width, 40);
        _errorLabel.frame = frame;
        _errorLabel.backgroundColor = [UIColor whiteColor];
        _errorLabel.textColor = [UIColor redColor];
        [_errorLabel setFont:[UIFont systemFontOfSize:12]];
        [_errorLabel setText:@""];
    }
    return _errorLabel;
}
-(void)textFiledEditChanged:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    if ([textField isEqual:self.nameTextField]) {
        NSString *toBeString = textField.text;
        if (toBeString.length > 10 && toBeString.length>1) {
            textField.text = [toBeString substringToIndex:10];
        }
    } else {
        NSString *toBeString = textField.text;
        if (toBeString.length > 20 && toBeString.length>1) {
            textField.text = [toBeString substringToIndex:20];
        }
    }
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    [self joinAndLive];
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
//     if (string.length == 0 || [textField isEqual:self.nameTextField]) return YES;
//        NSString *toStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
//        NSString *regex = @"^[A-Za-z0-9]+$";
//        return [self validateStr:toStr withRegex:regex];
}
- (BOOL)validateStr:(NSString *)string withRegex:(NSString *)regex
{
    NSPredicate *resultStr = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [resultStr evaluateWithObject:string];
}
- (void)joinAndLive{
//    RCCRSettingViewController *setting = [[RCCRSettingViewController alloc] init];
//    setting.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//    [self.navigationController presentViewController:setting animated:NO completion:nil];
//    return;
    if ((!self.liveRoomTextfield.text || self.liveRoomTextfield.text.length <= 0) && (!self.nameTextField.text || self.nameTextField.text.length <= 0)) {
        [self showError:@"直播间和主播名称不能为空！"];
        return;
    }
    if (!self.liveRoomTextfield.text || self.liveRoomTextfield.text.length <= 0) {
        [self showError:@"直播间名称不能为空！"];
        return;
    }
    if ( !self.nameTextField.text || self.nameTextField.text.length <= 0) {
        [self showError:@"主播名称不能为空！"];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.liveBtn.enabled = NO;
        [RCActiveWheel showHUDAddedTo:self.view];
    });
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] connectWithUserId:@"" userName:self.nameTextField.text portraitUri:nil success:^(NSString *userId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.liveBtn.enabled = YES;
            [self.navigationController popViewControllerAnimated:YES];
            if (self.CompletionBlock) {
                self.CompletionBlock((self.liveRoomTextfield.text) , self.model);
            }
        });
        
    } error:^(RCConnectErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.liveBtn.enabled = YES;
        });
        [self showError:@"加入直播间链接IM失败"];
    } tokenIncorrect:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.liveBtn.enabled = YES;
        });
        [self showError:@"加入直播间token无效"];
    }];
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}
-(void)dealloc{
    NSLog(@"");
}
- (void)showError:(NSString *)text{
    dispatch_async(dispatch_get_main_queue(), ^{
        [RCActiveWheel dismissForView:self.view];
        self.errorLabel.text = text;
    });
}

@end
