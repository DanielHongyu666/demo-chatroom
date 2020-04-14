//
//  RCCRBackgroundView.m
//  ChatRoom
//
//  Created by 孙承秀 on 2019/9/4.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCCRBackgroundView.h"
#import "RCCRLoginView.h"
#import "RCCRUtilities.h"
#import "RCCRRongCloudIMManager.h"
#import "RCCRLiveHttpManager.h"
#import "RCCRManager.h"
#import "RCActiveWheel.h"
@interface RCCRBackgroundView()<RCCRLoginViewDelegate,UIGestureRecognizerDelegate>


/**
 登录的界面
 */
@property(nonatomic,strong)RCCRLoginView *loginView;

@end
@implementation RCCRBackgroundView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        CGSize size = frame.size;
        self.backgroundColor = [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:0.8];
        [self addSubview:self.loginView];
        self.hidden = YES;
        self.loginView.delegate = self;
        [_loginView setFrame:CGRectMake(10, size.height,size.width - 20, ISX ? 244 : 210)];
        [_loginView setBackgroundColor:[UIColor whiteColor]];
        [_loginView setHidden:YES];
        _loginView.layer.cornerRadius = 8;
        _loginView.layer.masksToBounds = YES;
        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchView)];
           ges.delegate = self;
           [self addGestureRecognizer:ges];
    }
    return self;
}
- (void)touchView{
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchedBackgroundView)]) {
        [self.delegate touchedBackgroundView];
    }
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    NSLog(@"view class is %@",[touch.view class]);
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"RCCRBackgroundView"] ) {
        return YES;
    }
    return NO;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}
- (RCCRLoginView *)loginView {
    if (!_loginView) {
        _loginView = [[RCCRLoginView alloc] init];
//        [_loginView setAlpha:0.8];
        [_loginView setDelegate:self];
    }
    return _loginView;
}
- (void)present{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loginView addObserver];
        self.hidden = NO;
        CGRect frame = CGRectMake(10, self.frame.size.height / 2 - (ISX ? 244 : 210) / 2 - 30 - 50, self.frame.size.width - 20, ISX ? 264 : 230);
        [self.loginView setHidden:NO];
        [UIView animateWithDuration:0.2 animations:^{
            [self.loginView setFrame:frame];
        } completion:nil];
    });
}
- (void)dismiss{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loginView removeObserver];
        [RCActiveWheel dismissForView:self];
        [[UIApplication sharedApplication].keyWindow endEditing:YES];
        self.hidden = YES;
        CGRect frame = CGRectMake(10, self.frame.size.height, self.frame.size.width - 20, ISX ? 244 : 210);
        [self.loginView setHidden:YES];
        [UIView animateWithDuration:0.2 animations:^{
            [self.loginView setFrame:frame];
        } completion:nil];
    });
}
-(void)clickLoginBtn:(UIButton *)loginBtn userName:(NSString *)userName model:(RCCRLiveModel *)model{
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] connectWithUserId:@"" userName:userName portraitUri:model.hostPortrait success:^(NSString *userId) {
        [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] setIsLogin:YES];
        [[UIApplication sharedApplication].keyWindow endEditing:YES];
        if (self.delegate && [self.delegate respondsToSelector:@selector(connectSuccess)]) {
            [self.delegate connectSuccess];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [RCActiveWheel dismissForView:self];
        });
    } error:^(RCConnectErrorCode status) {
        
    } tokenIncorrect:^{
        
    }];
}
@end
