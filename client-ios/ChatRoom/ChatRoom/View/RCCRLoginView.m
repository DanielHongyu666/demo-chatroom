//
//  RCCRLoginView.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/11.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "RCCRLoginView.h"
#import "RCActiveWheel.h"

@interface RCCRLoginView ()<UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UILabel *titleLbl;

@property (nonatomic, strong) UIButton *loginBtn;

/**
 头像
 */
@property(nonatomic , strong)UIImageView *imageView;

/**
 name
 */
@property(nonatomic , strong)UITextField *nameTextfield;

/**
 line
 */
@property(nonatomic , strong)UILabel *line;

/**
 ori frame
 */
@property(nonatomic , assign)CGRect oriFrame;

/**
 live model
 */
@property(nonatomic , strong)RCCRLiveModel *model ;

/**
 error label
 */
@property(nonatomic , strong)UILabel *errorLabel;

/**
 ges
 */
@property(nonatomic , strong)UIGestureRecognizer *ges;

@end

@implementation RCCRLoginView

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.oriFrame = frame;
   
    
}
- (void)addObserver{
    RCCRLiveModel *model = [[RCCRLiveModel alloc] init];
    model.hostPortrait = [NSString stringWithFormat:@"%d",arc4random() % 5 + 1];
    model.audienceAmount = 0;
    model.fansAmount = 0;
    model.giftAmount = 0;
    model.praiseAmount = 0;
    model.attentionAmount = 0;
    self.model = model;
   
    [self initializedSubViews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.nameTextfield];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)touchLogIn{
    NSLog(@"点击登录界面");
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
     NSLog(@"view class is %@",[touch.view class]);
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"RCCRLoginView"] ) {
        return YES;
    }
    return NO;
}
- (void)removeObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)keyboardWillChangeFrame:(NSNotification *)notification{
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat transformY = keyboardFrame.origin.y ;

    [UIView animateWithDuration:duration animations:^{
        self.frame = CGRectMake(self.frame.origin.x, transformY - 100 - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    }];
}
- (void)showError:(NSString *)text{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.errorLabel.text = text;
    });
}
#pragma mark --键盘收回
- (void)keyboardDidHide:(NSNotification *)notification{
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        self.frame = self.oriFrame;
    }];
}
- (void)loginClick:(UIButton *)sender {
    if (!self.nameTextfield.text || self.nameTextfield.text.length <= 0) {
        [self showError:@"名字不能为空"];
        return;
    }
    [RCActiveWheel showHUDAddedTo:self];
    if ([self.delegate respondsToSelector:@selector(clickLoginBtn:userName:model:)]) {
        [self.delegate clickLoginBtn:sender userName:self.nameTextfield.text model:self.model];
    }
}

- (void)initializedSubViews {
    [self addSubview:self.titleLbl];
    CGSize size = self.bounds.size;
    [_titleLbl setFrame:CGRectMake((size.width - 200)/2, 10, 200, 30)];
    
    
    
    [self addSubview:self.imageView];
    [_imageView setFrame:CGRectMake(10, 66, 65, 65)];
    [_imageView.layer setCornerRadius:32.5];
    [_imageView.layer setMasksToBounds:YES];
    [_imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"audience%@",self.model.hostPortrait]]];
    
    [self addSubview:self.nameTextfield];
    [self.nameTextfield setFrame:CGRectMake(_imageView.frame.origin.x + _imageView.frame.size.width + 10, 70, self.frame.size.width - _imageView.frame.origin.x - _imageView.frame.size.width - 20, 30)];
    [self addSubview:self.line];
    [_line setFrame:CGRectMake(self.bounds.origin.x, self.frame.size.height - 43, self.bounds.size.width, 1)];
    
    [self addSubview:self.loginBtn];
    [_loginBtn setFrame:CGRectMake((size.width - 200)/2, self.frame.size.height - 23, 200, 20)];
    [_loginBtn.layer setCornerRadius:4];
    [_loginBtn.layer setMasksToBounds:YES];
    [self addSubview:self.errorLabel];
   
}

- (UILabel *)titleLbl {
    if (!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        [_titleLbl setTextAlignment:NSTextAlignmentCenter];
        [_titleLbl setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:15]];
        [_titleLbl setNumberOfLines:1];
        [_titleLbl setTextColor:[UIColor blackColor]];
        [_titleLbl setText:@"观众登录"];
    }
    return  _titleLbl;
}

- (UIButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [[UIButton alloc] init];
        [_loginBtn addTarget:self action:@selector(loginClick:) forControlEvents:UIControlEventTouchUpInside];
        [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        [_loginBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:15]];
        [_loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return  _loginBtn;
}
-(UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [_imageView setBackgroundColor:[UIColor redColor]];
    }
    return _imageView;
}
-(UITextField *)nameTextfield{
    if (!_nameTextfield) {
        _nameTextfield = [[UITextField alloc] init];
        _nameTextfield.font = [UIFont systemFontOfSize:12];
        _nameTextfield.textColor = [UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0];
        _nameTextfield.textAlignment = NSTextAlignmentLeft;
        _nameTextfield.keyboardType = UIKeyboardTypeDefault;
        _nameTextfield.returnKeyType = UIReturnKeyDone;
        _nameTextfield.borderStyle = UITextBorderStyleRoundedRect;
        _nameTextfield.placeholder = @"请输入直播观众名称（1-10个字符）";
        _nameTextfield.delegate = self;
        _nameTextfield.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    }
    return _nameTextfield;
}
-(UILabel *)line{
    if (!_line) {
        _line = [[UILabel alloc] init];
        [_line setBackgroundColor:[UIColor blackColor]];
    }
    return _line;
}
-(UILabel *)errorLabel{
    if (!_errorLabel) {
        _errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.nameTextfield.frame.origin.x, self.nameTextfield.frame.origin.y + self.nameTextfield.frame.size.height + 3, self.nameTextfield.frame.size.width, 16)];
        _errorLabel.backgroundColor = [UIColor whiteColor];
        _errorLabel.textColor = [UIColor redColor];
        [_errorLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:12]];
        [_errorLabel setText:@""];
    }
    return _errorLabel;
}
-(void)textFiledEditChanged:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    if (toBeString.length > 10 && toBeString.length>1) {
        textField.text = [toBeString substringToIndex:10];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (!self.nameTextfield.text || self.nameTextfield.text.length <= 0) {
        [self showError:@"名字不能为空"];
           return NO;
    }
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    return YES;
}
@end
