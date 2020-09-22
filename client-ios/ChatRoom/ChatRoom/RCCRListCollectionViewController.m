//
//  RCCRListCollectionViewController.m
//  ChatRoom
//
//  Created by RongCloud on 2018/5/9.
//  Copyright © 2018年 rongcloud. All rights reserved.
//

#import "RCCRListCollectionViewController.h"
#import "RCCRListCollectionViewCell.h"
#import <RongIMLib/RongIMLib.h>
#import "RCCRLiveChatRoomViewController.h"
#import "RCCRRongCloudIMManager.h"
#import "RCCRManager.h"
#import "RCCRLiveModel.h"
#import "MBProgressHUD.h"
#import "RCCRLiveHttpManager.h"
#import "RCCRLoginView.h"
#import "RCCRUtilities.h"
#import "RCChatroomWelcome.h"
#import "RCCRBackgroundView.h"
#import "RCCRBackgroundView.h"
#import "RCCRLiveViewController.h"
#import "RCActiveWheel.h"
#import "RCCRUtilities.h"
#import "RCLabel.h"
#import "RCCRUtilities.h"
#import "RCCRCDNViewController.h"
#import "RCCRSettingViewController.h"
#define WIDTH [UIScreen mainScreen].bounds.size.width

@interface RCCRListCollectionViewController ()<RCConnectDelegate>

@property (nonatomic, strong) NSMutableArray<RCCRLiveModel *> *hostArray;

@property (nonatomic, strong) NSIndexPath *selectIndexPath;

/**
 直播按钮
 */
@property(nonatomic , strong)UIButton *liveBtn;


/**
 background
 */
@property(nonatomic , strong)RCCRBackgroundView *backgroundView;

/**
 first btn
 */
@property(nonatomic , strong)UIButton *firstBtn;

/**
 line
 */
@property(nonatomic , strong)UILabel *line;

/**
 version label
 */
@property(nonatomic , strong)RCLabel *versionLabel;
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
    // 用于弹框测试
    [RCCRLiveHttpManager sharedManager].chatVC = self;
    self.hostArray = [[NSMutableArray alloc] init];
    self.title = @"直播";
    // 注册cell
    [self.collectionView registerClass:[RCCRListCollectionViewCell class] forCellWithReuseIdentifier:RCCRListCollectionViewCellReuseIdentifier];
    if (![RCCRUtilities isPhoneX]) {
        self.collectionView.contentInset = UIEdgeInsetsMake(0, 2, 50, 2);
    } else {
        self.collectionView.contentInset = UIEdgeInsetsMake(0, 2, 5, 2);
    }
    
    //隐藏水平滚动条
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.backgroundView = [[RCCRBackgroundView alloc] initWithFrame:self.view.frame];
    self.backgroundView.delegate = self;
    [self.view addSubview:self.backgroundView];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(connectChangeNotification:)
     name:RCCRConnectChangeNotification
     object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blowView:) name:@"blowView" object:nil];
    
    self.liveBtn = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 80) / 2, self.view.frame.size.height - 80 - 60, 80, 80)];
    [self.liveBtn setImage:[UIImage imageNamed:@"jiahao"] forState:UIControlStateNormal];
    [self.liveBtn addTarget:self action:@selector(beginLive) forControlEvents:UIControlEventTouchUpInside];
    [[UIApplication sharedApplication].keyWindow addSubview:self.liveBtn];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 20, 20);
    [btn setImage:[UIImage imageNamed:@"shuaxin"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [rightView addSubview:btn];
    UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    self.navigationItem.rightBarButtonItem = btnItem;
    [self.view addSubview:self.firstBtn];
    [self.view addSubview:self.line];
    [self setHidden:self.hostArray.count];
    
    // 版本号
    RCLabel *versionLabel = [[RCLabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60 , [UIScreen mainScreen].bounds.size.width, 60)];
    versionLabel.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication].keyWindow addSubview:versionLabel];
    NSString *version = [RCCRUtilities getDemoVersion];
    NSString *sdk = [RCCRUtilities getRTCLibSDKVersion];
    //SealLive v2.0.2 , RTCLib v3.2.1
    NSString *str = [NSString stringWithFormat:@"SealLive v%@ , RTCLib v%@",version,sdk];
    [versionLabel makeConfig:^(RCLabel *lab) {
        lab.labelText(str).titleColor([UIColor lightGrayColor]).alignment(UITextAlignmentCenter);
        lab.titleFont([UIFont fontWithName:@"PingFangSC-Regular" size:13]);
    }];
    self.versionLabel = versionLabel;
    
    [self checkAppVersion];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.liveBtn.hidden = NO;
    self.versionLabel.hidden = NO;
    [self fetchList];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.liveBtn.hidden = YES;
    self.versionLabel.hidden = YES;
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
    if (![[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] isLogin]){
        //  弹出登录框
        self.liveBtn.enabled = NO;
        self.versionLabel.enabled = NO;
        [self.backgroundView present];
        
    } else {
        self.selectIndexPath = indexPath;
        dispatch_async(dispatch_get_main_queue(), ^{
            RCCRLiveChatRoomViewController *vc = [[RCCRLiveChatRoomViewController alloc] init];
            vc.conversationType = ConversationType_CHATROOM;
            vc.model = model;
            vc.roomID = model.roomId;
            vc.roomName = model.roomName;
            // 测试
            model.liveMode = RCCRLiveModeAudience;
            [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] setIsLogin:YES];
            vc.targetId = model.roomId;
             if (![self isLocked:model.roomId]) {
                   [self.navigationController pushViewController:vc animated:YES];
               } else {
                   [self showAlertController:@"您已被管理员封禁" actionTitle:@"换个直播间"];
               }
        });
    }
    
}
- (void)blowView:(UIViewController *)v{
//    UIViewController *v = noti.object;
    [ [UIApplication sharedApplication].keyWindow bringSubviewToFront:v.view];
    self.liveBtn.enabled = NO;
    self.versionLabel.enabled = NO;
//    [ [UIApplication sharedApplication].keyWindow insertSubview:self.versionLabel belowSubview:v.view];

    
}
-(void)touchedBackgroundView{
    [self dismiss];
}
-(void)connectSuccess{
    [self dismiss];
    RCCRLiveModel *model = self.hostArray[self.selectIndexPath.row];;
    RCCRLiveChatRoomViewController *vc = [[RCCRLiveChatRoomViewController alloc] init];
    vc.conversationType = ConversationType_CHATROOM;
    vc.model = model;
    vc.targetId = model.roomId;
    vc.roomName = model.roomName;
    vc.roomID = model.roomId;
    if (![self isLocked:model.roomId]) {
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [self showAlertController:@"您已被管理员封禁" actionTitle:@"换个直播间"];
    }
    
}
- (BOOL)isLocked:(NSString *)roomId{
    return [[RCCRUtilities instance] isLockedRoom:roomId];
}
- (void)dismiss{
    self.liveBtn.enabled = YES;
    self.versionLabel.enabled = YES;
    [self.backgroundView dismiss];
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
- (void)refresh{
    [self fetchList];
}
- (void)beginLive{
//    RCCRSettingViewController *setting = [[RCCRSettingViewController alloc] init];
//    setting.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//  
//    [self.navigationController presentViewController:setting animated:NO completion:nil];
//    return;
    RCCRLiveViewController *live = [[RCCRLiveViewController alloc] init];
    live.CompletionBlock = ^(NSString * _Nonnull roomName , RCCRLiveModel *model) {
        NSString *oriName = roomName;
//        BOOL has = [self hasChinese:roomName];
        if (1) {
            roomName = [RCCRUtilities md5:roomName ];
            NSData *data = [roomName dataUsingEncoding:NSUTF8StringEncoding];
            roomName = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed]; // base64格式的字符串
            NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"[^a-zA-Z0-9]" options:0 error:nil];
            roomName = [regularExpression stringByReplacingMatchesInString:roomName options:0 range:NSMakeRange(0, roomName.length) withTemplate:@""];
        }
        NSString *roomID = [@"iOS-" stringByAppendingFormat:@"%@-%.0f",roomName,[[NSDate date] timeIntervalSince1970] * 1000];
        roomID = [roomID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        roomID = [roomID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
        if (roomID.length > 64) {
            roomID = [roomID substringToIndex:63];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            RCCRLiveChatRoomViewController *vc = [[RCCRLiveChatRoomViewController alloc] init];
            vc.conversationType = ConversationType_CHATROOM;
            model.hostName = oriName;
            model.pubUserId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
            model.roomId = roomID;
            vc.model = model;
            vc.roomID = roomID;
            vc.roomName = oriName;
            model.liveMode = RCCRLiveModeHost;
            vc.targetId = roomID;
            [RCActiveWheel dismissForView:self.view];
            [self.navigationController pushViewController:vc animated:YES];
        });
        
    };
    [self.navigationController pushViewController:live animated:YES];
}

-(BOOL)hasChinese:(NSString *)str {
    for(int i=0; i< [str length];i++){
        int a = [str characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff)
        {
            return YES;
        }
    }
    return NO;
}

- (void)fetchList{
    //  网络请求加载数据hostIcon,注释的为假数据
//      for (int i = 0; i<8; i++) {
//          int num = i + 1;
//          RCCRLiveModel *model = [[RCCRLiveModel alloc] init];
//          model.hostName = [NSString stringWithFormat:@"%d号主播",num];
//          model.hostPortrait = [NSString stringWithFormat:@"%d",i%6 + 1];
//          model.audienceAmount = 0;
//          model.fansAmount = 0;
//          model.giftAmount = 0;
//          model.praiseAmount = 0;
//          model.attentionAmount = 0;
//          model.liveMode = RCCRLiveModeAudience;
//          [self.hostArray addObject:model];
//      }
    
    [[RCCRLiveHttpManager sharedManager] query:@"" completion:^(BOOL isSuccess, NSArray * _Nullable list) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.hostArray removeAllObjects];
            for (NSDictionary *dic in list) {
                RCCRLiveModel *model = [[RCCRLiveModel alloc] init];
                model.date = dic[@"date"];
                model.roomId = dic[@"roomId"];
                model.roomName = dic[@"roomName"];
                model.cover = dic[@"coverIndex"] ;
                if (!model.cover) {
                    model.cover = @"0";
                }
                if ([model.cover integerValue] > 5 || [model.cover integerValue] < 0) {
                    model.cover = @"0";
                }
                model.liveUrl = dic[@"mcuUrl"];
                model.pubUserId = dic[@"pubUserId"];
                model.hostName = [NSString stringWithFormat:@"%@",model.roomName];
                model.hostPortrait = model.cover;
                // 测试
                model.liveMode = RCCRLiveModeAudience;
                [self.hostArray addObject:model];
            }
            [self setHidden:self.hostArray.count];
            [self.collectionView reloadData];
        });
    }];
      
}
- (void)setHidden:(BOOL)hidden{
    self.firstBtn.hidden = hidden;
    self.line.hidden = hidden;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)showAlertController:(NSString *)message actionTitle:(NSString *)title{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:action];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(UIButton *)firstBtn{
    if (!_firstBtn) {
        _firstBtn = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 112) / 2, 200, 112, 20)];
        [_firstBtn setTitle:@"创建第一个直播间" forState:UIControlStateNormal];
        [_firstBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_firstBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:14]];
        [_firstBtn addTarget:self action:@selector(beginLive) forControlEvents:UIControlEventTouchUpInside];
    }
    return _firstBtn;
}
-(UILabel *)line{
    if (!_line) {
        _line = [[UILabel alloc] initWithFrame:CGRectMake(self.firstBtn.frame.origin.x, self.firstBtn.frame.origin.y + self.firstBtn.frame.size.height, self.firstBtn.frame.size.width, 1)];
        [_line setBackgroundColor:[UIColor blueColor]];
    }
    return _line;
}
- (void)checkAppVersion
{
#ifdef DEBUG
#else
    NSString *bundleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    if ([bundleID isEqualToString:@"cn.rongcloud.livechat"]) {
        [[RCCRLiveHttpManager sharedManager] getDemoVersionInfo:^(NSDictionary * _Nonnull respDict) {
            if (respDict) {
                NSDictionary *clientDict = respDict[@"ios"];
                if (clientDict) {
                    NSDictionary *iOSDict = clientDict.copy;
                    if (iOSDict) {
                        NSString *ver = iOSDict[@"name"];
                        int force = [iOSDict[@"force"] intValue];
                        if (ver) {
                            NSString *version = [RCCRUtilities getDemoVersion];
                            NSInteger verCompare = [RCCRUtilities compareVersion:ver toVersion:version];
                            if (verCompare == 1) {
                                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                    NSString *updateURL = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", iOSDict[@"url"]];
                                    if ([updateURL containsString:@".plist"]) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateURL]];
                                            [self exitApplication];
                                        });
                                    }
                                }];
                                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        self.liveBtn.enabled = YES;
                                           self.versionLabel.enabled = YES;
                                    });
                                }];
                                NSString *msg = [NSString stringWithFormat:@"检测到新版本V%@\n是否升级?",ver];
                                UIAlertController *controler = [UIAlertController alertControllerWithTitle:msg message:nil preferredStyle:UIAlertControllerStyleAlert];
                                if (!force) {
                                    [controler addAction:cancel];
                                }
                                [controler addAction:okAction];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:controler animated:YES completion:^{}];
                                    [self blowView:controler];
//                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"blowView" object:controler];
                                });
                            }
                        }
                    }
                }
            }
        }];
    }
#endif
}

- (void)exitApplication{

    exit(0);

}

@end
