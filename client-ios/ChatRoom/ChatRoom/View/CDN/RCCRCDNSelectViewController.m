//
//  RCCRCDNSelectViewController.m
//  ChatRoom
//
//  Created by 孙承秀 on 2020/5/29.
//  Copyright © 2020 罗骏. All rights reserved.
//

#import "RCCRCDNSelectViewController.h"
#import "RCCRLiveHttpManager.h"
#import "Masonry.h"
#import "RCActiveWheel.h"
#define CELLID @"cellID"
@interface RCCRCDNSelectViewController()<UITableViewDelegate,UITableViewDataSource>

/**
 tableView
 */
@property(nonatomic , strong)UITableView *tableView;

/**
 datas
 */
@property(nonatomic , strong)NSMutableArray *datas;
@end
@implementation RCCRCDNSelectViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // 用于弹框测试
    [RCCRLiveHttpManager sharedManager].chatVC = self;
    [self addSubview];
    [self getSelectList];
}
- (void)addSubview{
    self.datas = [NSMutableArray array];
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).offset(0);
    }];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    ;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datas.count;;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellID= CELLID;
    UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    NSDictionary *dic = self.datas[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"name : %@",dic[@"name"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"cdnId : %@",dic[@"cdnId"]];
    return cell;;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [RCActiveWheel showHUDAddedTo:self.view];
    [self getCDNList:indexPath];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}
- (void)getCDNList:(NSIndexPath *)indexPath{
    NSDictionary *dic = self.datas[indexPath.row];
    [[RCCRLiveHttpManager sharedManager] getCdnListWithRoomId:self.model.roomId streamName:self.model.streamName appName:self.model.appName cdnId:dic[@"cdnId"] completion:^(BOOL success, NSArray * _Nonnull list) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [RCActiveWheel dismissForView:self.view];
            if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCDN:)]) {
                [self.delegate didSelectCDN:list];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        });
    }];
}
- (void)getSelectList{
    [[RCCRLiveHttpManager sharedManager] getCDNSupplyListWithRoomId:self.model.roomId completion:^(BOOL success, NSArray * _Nonnull list) {
        NSLog(@"%@",list);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.datas = list.mutableCopy;
            [self.tableView reloadData];
        });
    }];
}
@end
