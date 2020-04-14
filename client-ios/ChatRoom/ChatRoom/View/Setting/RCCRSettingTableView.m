//
//  RCCRSettingTableView.m
//  ChatRoom
//
//  Created by 孙承秀 on 2019/12/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCCRSettingTableView.h"
#define CELLID @"RCCRSETTINGCELL"
#import "UIColor+Helper.h"
#import "RCCRSettingHeaderView.h"
#import "RCCRFactoryTableViewCell.h"

@interface RCCRSettingTableView()<RCCRSwitchProtocol,RCCRSettingCellReturnProtocol>

/**
 type
 */
@property(nonatomic , assign)RCCRSwitchType switchType;

/**
 header view
 */
@property(nonatomic , strong)RCCRSettingHeaderView *headerView;

@end
@implementation RCCRSettingTableView
-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if (self = [super initWithFrame:frame style:style]) {
        self.delegate = self;
        self.dataSource = self;
        self.switchType = RCCRSwitchTypeAdaptive;
        [self registerClass:[RCCRAdaptiveTableViewCell class] forCellReuseIdentifier:ADAPTIVECELLID];
        [self registerClass:[RCCRSuspensionTableViewCell class] forCellReuseIdentifier:SUSPENSIONCELLID];
        [self registerClass:[RCCRCustomTableViewCell class] forCellReuseIdentifier:CUSTOMCELLID];
    }
    return self;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return self.headerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 90;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.frame.size.height - 90;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RCCRFactoryTableViewCell *factory = [[RCCRFactoryTableViewCell alloc] createCellWithTableView:tableView cellType:self.switchType];
    [factory process:self.settingModel];
    RCCRSettingBaseTableViewCell *baseCell = [factory product];
    baseCell.tableView = self;
    baseCell.returnDelegate = self.settingReturnDelegate;
    return baseCell;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(RCCRSettingHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[RCCRSettingHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 90)];
        _headerView.delegate = self;
    }
    return _headerView;
}
-(void)didSelectSwitchView:(UIView *)view type:(RCCRSwitchType)type{
    switch (type) {
        case RCCRSwitchTypeAdaptive:
        {
            
        }
            break;
        case RCCRSwitchTypeSuspension:{
            
        }
            break;
            case RCCRSwitchTypeCustom:
        {
            
        }
            break;
            
        default:
            break;
    }
    [self reloadDataWithType:type];
}
- (void)reloadDataWithType:(RCCRSwitchType)type{
    self.switchType = type;
    [self.headerView selectViewWithType:type];
    [self reloadData];
}
-(void)close{
    if (self.settingDelegate && [self.settingDelegate respondsToSelector:@selector(tableViewDidClosed:)]) {
        [self.settingDelegate tableViewDidClosed:self];
    }
}



@end
