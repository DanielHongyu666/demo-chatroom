//
//  RCCRListCollectionViewController.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/9.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "RCCRListCollectionViewController.h"
#import "RCCRListCollectionViewCell.h"
#import <RongIMLib/RongIMLib.h>
#import "RCCRLiveChatRoomViewController.h"
#import "RCCRRongCloudIMManager.h"
#import "RCCRManager.h"
#import "RCCRLiveModel.h"
#import "MBProgressHUD.h"

#define WIDTH [UIScreen mainScreen].bounds.size.width
@interface RCCRListCollectionViewController ()

@property (nonatomic, strong) NSMutableArray<RCCRLiveModel *> *hostArray;

@property (nonatomic, strong) NSIndexPath *selectIndexPath;

@end

@implementation RCCRListCollectionViewController

static NSString * const RCCRListCollectionViewCellReuseIdentifier = @"RCCRListCollectionViewCell";

- (instancetype)init {
    //创建流水布局对象
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    // 定义大小
    layout.itemSize = CGSizeMake((WIDTH - 20 - 2)/2, (WIDTH - 20 - 2)/2);;
    // 设置cell之间间距
    layout.minimumInteritemSpacing = 0;
    // 设置行距
    layout.minimumLineSpacing = 2;
    return [super initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hostArray = [[NSMutableArray alloc] init];
    self.title = @"融云直播";
    // 注册cell
    [self.collectionView registerClass:[RCCRListCollectionViewCell class] forCellWithReuseIdentifier:RCCRListCollectionViewCellReuseIdentifier];
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 2, 0, 2);
    //隐藏水平滚动条
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];

    [self.navigationController.navigationBar setTranslucent:NO];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(connectChangeNotification:)
     name:RCCRConnectChangeNotification
     object:nil];
    //  连接融云
    RCUserInfo *userInfo = [[RCUserInfo alloc] init];
    userInfo = [[RCCRManager sharedRCCRManager] getRandomUserInfo];
    NSString *token = [[RCCRManager sharedRCCRManager] defaultToken];
    
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] setCurrentUserInfo:userInfo];
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] connectRongCloudWithToken:token success:^(NSString *userId) {
        if (![userInfo.userId isEqualToString:userId]) {
            NSLog(@"id不一致");
        }
        NSLog(@"连接成功");
        
    } error:^(RCConnectErrorCode status) {
        NSLog(@"连接失败， error code：%ld",(long)status);
        NSLog(@"userId = %@, token = %@",userInfo.userId, token);
        
    } tokenIncorrect:^{
        NSLog(@"连接失败，token无效");

    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //  网络请求加载数据hostIcon
    for (int i = 0; i<8; i++) {
        int num = i + 1;
        RCCRLiveModel *model = [[RCCRLiveModel alloc] init];
        model.hostName = [NSString stringWithFormat:@"%d号主播",num];
        model.hostPortrait = [NSString stringWithFormat:@"hostIcon%d",i%6 + 1];
        model.audienceAmount = 0;
        model.fansAmount = 0;
        model.giftAmount = 0;
        model.praiseAmount = 0;
        model.attentionAmount = 0;
        [self.hostArray addObject:model];
    }
    [self.collectionView reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.hostArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCCRListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:RCCRListCollectionViewCellReuseIdentifier forIndexPath:indexPath];
    RCCRLiveModel *model = self.hostArray[indexPath.row];
    [cell setData:model];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RCCRLiveModel *model = self.hostArray[indexPath.row];
    [self loginRongCloud:model index:indexPath];
}

- (void)loginRongCloud:(RCCRLiveModel *)model index:(NSIndexPath *)indexPath{
    self.selectIndexPath = indexPath;
    RCConnectionStatus status = [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] getRongCloudConnectionStatus];
    if (status != ConnectionStatus_Connected) {
        RCUserInfo *userInfo = [[RCUserInfo alloc] init];
        userInfo = [[RCCRManager sharedRCCRManager] getUserInfo:[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].currentUserInfo.userId];
        NSString *token = [[RCCRManager sharedRCCRManager] defaultToken];
        
        [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] connectRongCloudWithToken:token success:^(NSString *userId) {
            if (![userInfo.userId isEqualToString:userId]) {
                NSLog(@"id不一致");
            }
            [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] setCurrentUserInfo:userInfo];
            NSLog(@"连接成功");
            __weak __typeof(&*self)weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                RCCRLiveChatRoomViewController *vc = [[RCCRLiveChatRoomViewController alloc] init];
                vc.conversationType = ConversationType_CHATROOM;
                vc.model = model;
                vc.targetId = [NSString stringWithFormat:@"ChatRoom%ld",(long)indexPath.row + 1];
                [weakSelf.navigationController pushViewController:vc animated:YES];
            });
            
        } error:^(RCConnectErrorCode status) {
            NSLog(@"连接失败， error code：%ld",(long)status);
            NSLog(@"userId = %@, token = %@",userInfo.userId, token);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlert:@"连接失效"];
            });
 
        } tokenIncorrect:^{
            NSLog(@"连接失败，token无效");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlert:@"token失效"];
            });
        }];
    } else {
        __weak __typeof(&*self)weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            RCCRLiveChatRoomViewController *vc = [[RCCRLiveChatRoomViewController alloc] init];
            vc.conversationType = ConversationType_CHATROOM;
            vc.model = model;
            vc.targetId = [NSString stringWithFormat:@"ChatRoom%ld",(long)indexPath.row + 1];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        });
    }
}

- (void)connectChangeNotification:(NSNotification *)notification {
    RCConnectionStatus status = [[notification.userInfo objectForKey:@"status"] intValue];
    if (status == ConnectionStatus_Connected) {
        NSLog(@"连接成功了");
    }
}

- (void)showAlert:(NSString *)showMessage {
    UIAlertController *alertController= [UIAlertController alertControllerWithTitle:showMessage message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    [self presentViewController:alertController animated:YES completion:nil];
    // 2秒后执行
    [self performSelector:@selector(dimissAlert:)withObject:alertController afterDelay:1.0];
}

- (void)dimissAlert:(UIAlertController *)alertController {
    [alertController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
