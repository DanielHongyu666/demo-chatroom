//
//  RCCRSettingViewController.m
//  ChatRoom
//
//  Created by 孙承秀 on 2019/12/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCCRSettingViewController.h"
#import "RCCRSettingTableView.h"
#import "RCCRSettingCellProtocol.h"
#define HEIGHT self.view.frame.size.height
#define WIDTH self.view.frame.size.width
#define HEADER 172
@interface RCCRSettingViewController ()<RCCRSettingTableViewDelegate,RCCRSettingCellReturnProtocol>

/**
 background view
 */
@property(nonatomic , strong)RCCRSettingTableView *settingTableView;
@end

@implementation RCCRSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    // Do any additional setup after loading the view.
    [self addSubviews];
}
- (void)addSubviews{
    [self.view addSubview:self.settingTableView];
    self.settingTableView.settingModel = self.settingModel;
    switch (self.settingModel.layoutModel.layoutType) {
        case RCCRLiveLayoutTypeCustom:
            [self.settingTableView reloadDataWithType:RCCRSwitchTypeCustom];
            break;
            case RCCRLiveLayoutTypeAdaptive:
            [self.settingTableView reloadDataWithType:RCCRSwitchTypeAdaptive];
            break;
            case RCCRLiveLayoutTypeSuspension:
            [self.settingTableView reloadDataWithType:RCCRSwitchTypeSuspension];
            break;
        default:
            break;
    }
    
}
-(RCCRSettingTableView *)settingTableView{
    if (!_settingTableView) {
        _settingTableView = [[RCCRSettingTableView alloc] initWithFrame:CGRectMake(0, HEADER, WIDTH, HEIGHT - HEADER) style:(UITableViewStylePlain)];
        _settingTableView.backgroundColor = [UIColor clearColor];
        _settingTableView.scrollEnabled = NO;
        _settingTableView.allowsSelection = NO;
        _settingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _settingTableView.settingDelegate = self;
        _settingTableView.settingReturnDelegate = self;
    }
    return _settingTableView;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}
-(void)didClickedCell:(UITableViewCell *)cell layout:(RCCRLiveLayoutModel *)model{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        if (self.clickSaveBlock) {
            self.clickSaveBlock(model);
        }
        [self dismissViewControllerAnimated:NO completion:nil];
    });
}
-(void)didTouchCell:(RCCRSettingBaseTableViewCell *)cell{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    });
}
-(void)tableViewDidClosed:(UITableView *)tableView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        [self dismissViewControllerAnimated:NO completion:nil];
    });
}
@end
