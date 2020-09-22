//
//  RCCRCDNViewController.m
//  ChatRoom
//
//  Created by 孙承秀 on 2020/5/25.
//  Copyright © 2020 罗骏. All rights reserved.
//

#import "RCCRCDNViewController.h"
#import "RCCRCDNAddStreamView.h"
#import "RCCRCDNListTableView.h"
#import "Masonry.h"
@interface RCCRCDNViewController ()<RCCRCDNPublishViewProtocol , RCCRListTableViewProtocol,UITextFieldDelegate>

/**
 publish stream view
 */
@property(nonatomic , strong)RCCRCDNAddStreamView *publishStreamView;

/**
 list table view
 */
@property(nonatomic , strong)RCCRCDNListTableView *listTableView;

/**
 keyboard
 */
@property(nonatomic , assign)CGFloat transformY;

@end

@implementation RCCRCDNViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self config];
}
- (void)config{
    //    self.view.backgroundColor = [UIColor redColor];
    self.view.backgroundColor = [UIColor clearColor];
    
    [self addPublishStreamView];
    [self addListTableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];

}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)addPublishStreamView{
    [self.view addSubview:self.publishStreamView];
}
- (void)addListTableView{
    [self.view addSubview:self.listTableView];
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self reloadListView];
    
}
- (void)reloadListView{
    float height = [self.listTableView height];

    [self.listTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom);
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.height.mas_equalTo(height);
    }];
    [self.publishStreamView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.listTableView.mas_top).offset( 0);
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.height.mas_equalTo(150);
    }];
}
-(RCCRCDNAddStreamView *)publishStreamView{
    if (!_publishStreamView) {
        _publishStreamView = [[RCCRCDNAddStreamView alloc] init];
        //        _publishStreamView.backgroundColor = [UIColor greenColor];
        _publishStreamView.delegate = self;
    }
    return _publishStreamView;
}
-(RCCRCDNListTableView *)listTableView{
    if (!_listTableView) {
        _listTableView = [[RCCRCDNListTableView alloc] init];
        _listTableView.listDelegate = self;
    }
    return _listTableView;
}
-(void)didClickClose{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)didAddCDNAddress:(NSDictionary *)cdn{
    NSString *pushUrl = cdn[@"pushUrl"];
    // 测试使用
    if (pushUrl == nil && cdn == nil) {
        cdn = @{@"pushUrl":@"123"};
        pushUrl = cdn[@"pushUrl"];
    }
    if (pushUrl && pushUrl.length > 0) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.listTableView addCDN:cdn];
            [self reloadListView];
            if (self.delegate && [self.delegate respondsToSelector:@selector(didAddCDN:controller:)]) {
                [self.delegate didAddCDN:pushUrl controller:self];
            }
        });
    }
}
-(void)didRemoveCDN:(NSDictionary *)cdn{
    NSString *hls = cdn[@"pushUrl"];
    if (hls && hls.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(didRemoveCDN:controller:)]) {
                [self.delegate didRemoveCDN:hls controller:self];
            }
            [self reloadListView];
        });
    }
}
-(void)didUpdateHeight{
    [self reloadListView];
}
#pragma mark --键盘弹出
- (void)keyboardWillChangeFrame:(NSNotification *)notification{
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat transformY = keyboardFrame.origin.y - self.view.frame.size.height;
    self.transformY = transformY;
    //执行动画
    [UIView animateWithDuration:duration animations:^{
        CGFloat y = self.publishStreamView.frame.origin.y;
        float height = [self.listTableView height];
        if ( [UIScreen mainScreen].bounds.size.height - y - 80< fabs(transformY) ) {

            [self.publishStreamView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.view).offset( transformY);
                make.left.mas_equalTo(self.view.mas_left);
                make.right.mas_equalTo(self.view.mas_right);
                make.height.mas_equalTo(150);
            }];
        }
    }];
}
#pragma mark --键盘收回
- (void)keyboardDidHide:(NSNotification *)notification{
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        self.transformY = 0;
        [self reloadListView];
        
    }];
}

@end
