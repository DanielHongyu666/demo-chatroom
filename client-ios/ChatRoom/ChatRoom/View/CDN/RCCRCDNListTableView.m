//
//  RCCRCDNListTableView.m
//  ChatRoom
//
//  Created by 孙承秀 on 2020/5/25.
//  Copyright © 2020 罗骏. All rights reserved.
//

#import "RCCRCDNListTableView.h"
#import "RCCRCDNListTableViewCell.h"
#import "RCCRCDNViewModel.h"
#import "RCCRCDNSelectViewController.h"
#import "RCActiveWheel.h"
static NSString const *ider = @"RCCRListTableViewCell";
@interface RCCRCDNListTableView()<UITableViewDelegate,UITableViewDataSource,RCCRListCellProtocol>

/**
 viewmodel
 */
@property(nonatomic , strong)RCCRCDNViewModel *viewModel;
@end
@implementation RCCRCDNListTableView
-(instancetype)init{
    if (self = [super init]) {
        self.delegate = self;
        self.dataSource = self;
        self.backgroundColor = [UIColor whiteColor];
        [self registerClass:[RCCRCDNListTableViewCell class] forCellReuseIdentifier:ider];
        self.viewModel = [[RCCRCDNViewModel alloc] init];
    }
    return self;
}
- (void)addCDN:(NSDictionary *)cdn{
    NSUInteger index = [self.viewModel addObject:cdn];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}
-(CGFloat)height{
    return ((self.viewModel.datas.count >= 5) ? (5 * 84 + 50) :(self.viewModel.datas.count * 84) + 50);
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RCCRCDNListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ider forIndexPath:indexPath];
    cell.delegate = self;
    [cell configWithCdn:self.viewModel.datas[indexPath.row]];
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.viewModel.datas.count ;;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 84;;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    return view;
}
- (void)didCopyCell:(RCCRCDNListTableViewCell *)cell{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [self indexPathForCell:cell];
        UIPasteboard*pasteboard = [UIPasteboard generalPasteboard];
        NSDictionary *cdn = self.viewModel.datas[indexPath.row];
        NSMutableDictionary *mdic = cdn.mutableCopy;
        NSMutableString *str = [NSMutableString string];
        NSString *part = @" -- ";
        if ([mdic.allKeys containsObject:@"hlsPlay"]) {
            [str appendString:cdn[@"hlsPlay"]];
            
        }
        if ([mdic.allKeys containsObject:@"rtmpPlay"]){
            [str appendString:part];
            [str appendString:cdn[@"rtmpPlay"]];
          
        }
        if ([mdic.allKeys containsObject:@"flvPlay"]){
            [str appendString:part];
            [str appendString:cdn[@"flvPlay"]];
        }
      
        pasteboard.string = str;
        [RCActiveWheel showPromptHUDAddedTo:self.superview text:@"复制成功"];
    });
    
}
- (void)didDeleteCell:(RCCRCDNListTableViewCell *)cell{
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    NSDictionary *cdn = [self.viewModel removeObjAtIndex:indexPath.row];
    [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationFade)];
    if (self.listDelegate && [self.listDelegate respondsToSelector:@selector(didUpdateHeight)]) {
        [self.listDelegate didUpdateHeight];
        [self.listDelegate didRemoveCDN:cdn];
    }
}
@end
