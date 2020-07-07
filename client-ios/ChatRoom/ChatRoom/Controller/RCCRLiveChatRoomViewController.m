//
//  RCCRLiveChatRoomViewController.m
//  ChatRoom
//
//  Created by RongCloud on 2018/5/9.
//  Copyright © 2018年 rongcloud. All rights reserved.
//

#import "RCCRLiveChatRoomViewController.h"
#import "RCCRInputBarControl.h"
#import "RCCRMessageModel.h"
#import "RCCRUtilities.h"
#import "RCCRPortraitCollectionViewCell.h"
#import "RCCRMessageBaseCell.h"
#import "RCCRHostInformationView.h"
#import "RCCRAudienceListView.h"
#import "RCCRgiftListView.h"
#import "RCCRLoginView.h"
#import "RCCRRongCloudIMManager.h"
#import "RCCRTextMessageCell.h"
#import "UIView+RCDDanmaku.h"
#import "RCDDanmaku.h"
#import "RCDDanmakuManager.h"
#import "RCCRLiveHttpManager.h"
#import "RCChatRoomLiveCommand.h"
#import "UIColor+Helper.h"
#define kRandomColor [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:1]

static NSString * const portraitCollectionViewCell = @"portraitCollectionViewCell";

#import "RCChatroomWelcome.h"
#import "RCChatroomGift.h"
#import "RCCRManager.h"
#import "RCChatroomLike.h"
#import "RCChatroomBarrage.h"
#import "RCChatroomFollow.h"
#import "RCChatroomUserQuit.h"
#import "RCCRGiftNumberLabel.h"
#import "RCChatroomStart.h"
#import "RCChatroomEnd.h"
#import "RCChatroomUserBan.h"
#import "RCChatroomUserUnBan.h"
#import "RCChatroomUserBlock.h"
#import "RCChatroomUserUnBlock.h"
#import "RCChatroomNotification.h"
#import "RCCRRemoteView.h"
#import "RCCRLiveModuleManager.h"
#import "RCChatRoomNotiAllMessage.h"
#import "RCActiveWheel.h"
#import "RCCRSettingViewController.h"
#import "RCCRButtonBar.h"
#import "Masonry.h"
#import "RCCRFileCapture.h"
#import "RCCRCDNViewController.h"
static NSString * const banNotifyContent = @"您已被管理员禁言";

#define kRandomColor [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:1]


#define KMAXCOUNT 5000000

static NSString * const portraitCollectionViewCellIndentifier = @"portraitCollectionViewCellIndentifier";

static NSString * const ConversationMessageCollectionViewCell = @"ConversationMessageCollectionViewCell";

/**
 *  文本cell标示
 */
static NSString *const textCellIndentifier = @"textCellIndentifier";

static NSString *const startAndEndCellIndentifier = @"startAndEndCellIndentifier";

@interface RCCRLiveChatRoomViewController () <UICollectionViewDelegate, UICollectionViewDataSource, RCCRInputBarControlDelegate, UIGestureRecognizerDelegate, RCCRLoginViewDelegate, RCCRGiftViewDelegate, RCCRHostInformationViewDelegate , RCCRLiveModuleDelegate , RCCRAudienceDelegate , RCCRRemoteViewDelegate,RCCRButtonBarDelegate,RongRTCFileCapturerDelegate,RCCRCDNProtocol>

/**
 连麦数量
 */
@property(nonatomic , strong)NSMutableArray *acceptUsers;


/**
 *  播放器view
 */
@property(nonatomic,strong) UIView *liveView;

/**
 顶部控件容器，包括返回按钮，主播头像，用户头像等
 */
@property(nonatomic,strong) UIView *topContentView;

/**
 主播信息界面
 */
@property(nonatomic,strong) RCCRHostInformationView *hostInformationView;

/**
 主播头像所在view
 */
@property(nonatomic,strong) UIView *hostView;

/**
 主播头像
 */
@property(nonatomic,strong) UIImageView *hostPortraitImgV;

/**
 主播名称
 */
@property(nonatomic,strong) UILabel *hostNameLbl;

/**
 观看人数
 */
@property(nonatomic,strong) UILabel *audienceNumberLbl;

/**
 顶部头像展示CollectionView
 */
@property(nonatomic,strong)UICollectionView *portraitCollectionView;

/**
 观众列表
 */
@property(nonatomic,strong)RCCRAudienceListView *audienceListView;

/**
 oriframe
 */
@property(nonatomic , assign)CGRect oriFrame;


/**
 *  返回按钮
 */
@property (nonatomic, strong) UIButton *backBtn;

/*!
 消息列表CollectionView和输入框都在这个view里
 */
@property(nonatomic, strong) UIView *messageContentView;

/*!
 会话页面的CollectionView
 */
@property(nonatomic, strong) UICollectionView *conversationMessageCollectionView;

/**
 输入工具栏
 */
@property(nonatomic,strong) RCCRInputBarControl *inputBar;

/**
 底部按钮容器，底部的四个按钮都添加在此view上
 */
@property(nonatomic, strong) UIView *bottomBtnContentView;

/**
 *  评论按钮
 */
@property(nonatomic,strong)UIButton *commentBtn;

/**
 *  弹幕消息按钮
 */
@property(nonatomic,strong)UIButton *danmakuBtn;


/**
 *  礼物按钮
 */
@property(nonatomic,strong)UIButton *giftBtn;

/**
 礼物列表
 */
@property(nonatomic,strong)RCCRGiftListView *giftListView;

/**
 *  赞按钮
 */
@property(nonatomic,strong)UIButton *praiseBtn;

/**
 主播设置按钮
 */
@property(nonatomic , strong)UIButton *settingBtn;


/**
 *  是否需要滚动到底部
 */
@property(nonatomic, assign) BOOL isNeedScrollToButtom;

/**
 *  滚动条不在底部的时候，接收到消息不滚动到底部，记录未读消息数
 */
@property (nonatomic, assign) NSInteger unreadNewMsgCount;

/*!
 聊天内容的消息Cell数据模型的数据源
 
 @discussion 数据源中存放的元素为消息Cell的数据模型，即RCDLiveMessageModel对象。
 */
@property(nonatomic, strong) NSMutableArray<RCCRMessageModel *> *conversationDataRepository;

/**
 观众数据模型的数据源
 */
@property(nonatomic, strong) NSMutableArray<RCCRAudienceModel *> *audienceList;

/**
 加入聊天室时间，用于判断是否暂时部分历史消息
 */
//@property(nonatomic, assign) CGFloat joinTime;

/**
 判断是否发送弹幕
 */
@property(nonatomic, assign) BOOL isSendDanmaku;


/**
 处理礼物消息
 */
@property(nonatomic, assign) BOOL forbidGiftAinimation;

/**
 展示礼物动画数字的label
 */
@property(nonatomic,strong) RCCRGiftNumberLabel *giftNumberLbl;

/**
 展示礼物动画的界面
 */
@property(nonatomic,strong) UIView *showGiftView;

/**
 上次点赞按钮点击时间
 */
@property(nonatomic, assign) NSTimeInterval lastClickPraiseTime;

/**
 rtc engine
 */
@property(nonatomic , strong)RCCRLiveModuleManager *liveModuleManager;

/**
 local view
 */
@property(nonatomic , strong)RCRTCLocalVideoView *localView;

/**
 remote view
 */
@property(nonatomic , strong)RCRTCRemoteVideoView *remoteVideoView;

/**
 remote view
 */
@property(nonatomic , strong)RCCRRemoteView *remoteView ;

/**
 all live users
 */
@property(nonatomic , strong)NSMutableArray *allLiveUsers;

/**
 select model
 */
@property(nonatomic , strong)RCCRRemoteModel *selectModel;

/**
 remote cell
 */
@property(nonatomic , strong)RCCRRemoteViewCellCollectionViewCell *selectCell;

/**
 selectindexpath
 */
@property(nonatomic , strong)NSIndexPath *selectIndexPath;

/**
 selectmodel
 */
@property(nonatomic , strong)RCCRRemoteModel *remoteModel;

/**
 原始角色
 */
@property(nonatomic , assign)RCCRLiveMode oriModel;

/**
 local is remote
 */
@property(nonatomic , assign)BOOL localIsRemote;

/**
 setting model
 */
@property(nonatomic , strong)RCCRSettingModel *settingModel;

/**
 alert
 */
@property(nonatomic , strong)UIAlertController *alert;

/**
 localView frame
 */
@property(nonatomic , assign)CGRect localViewFrame;

/**
 bar
 */
@property(nonatomic , strong)RCCRButtonBar *buttonBar;


/**
 file stream
 */
@property(nonatomic , strong)RCRTCVideoOutputStream *fileStream;

/**
 file capture
 */
@property(nonatomic , strong)RCCRFileCapture *fileCapture;
@property (nonatomic, strong) RCRTCLocalVideoView *localFileVideoView;

/**
 fileModel
 */
@property(nonatomic , strong)RCCRRemoteModel *fileModel;

@end

//  用于记录点赞消息连续点击的次数
static int clickPraiseBtnTimes  = 0 ;

@implementation RCCRLiveChatRoomViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self rcinit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self rcinit];
    }
    return self;
}

- (void)rcinit {
    self.conversationDataRepository = [[NSMutableArray alloc] init];
    self.audienceList = [[NSMutableArray alloc] init];
    self.acceptUsers = [NSMutableArray array];
    self.allLiveUsers = [NSMutableArray array];
    self.conversationMessageCollectionView = nil;
    self.targetId = nil;
    [self registerNotification];
    self.defaultHistoryMessageCountOfChatRoom = 10;
    self.lastClickPraiseTime = 0;
    self.liveModuleManager = [[RCCRLiveModuleManager alloc] init];
    self.liveModuleManager.chatVC = self;
    self.liveModuleManager.delegate = self;
    self.oriModel = self.model.liveMode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.model.liveMode == RCCRLiveModeHost) {
        self.isOwer = YES;
    } else {
        self.isOwer = NO;
    }
    
    //默认进行弹幕缓存，不过量加载弹幕，如果想要同时大批量的显示弹幕，设置为yes，弹幕就不会做弹道检测和缓存
    RCDanmakuManager.isAllowOverLoad = NO;
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor: [UIColor whiteColor]];
    [self initializedSubViews];
    
    //    self.livePlayingManager = [[KSYLivePlaying alloc] initPlaying:self.contentURL];
    //    self.liveView = self.livePlayingManager.currentLiveView;
    //    [self.liveView setFrame:self.view.frame];
    //    [self.view addSubview:self.liveView];
    //    [self.view sendSubviewToBack:self.liveView];
    //聊天室类型=时需要调用加入聊天室接口，退出时需要调用退出聊天室接口
    if (ConversationType_CHATROOM == self.conversationType) {
        //        __weak __typeof(&*self)weakSelf = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[RCIMClient sharedRCIMClient] joinChatRoom:self.targetId messageCount:-1 success:^{
                RCChatroomWelcome *joinChatroomMessage = [[RCChatroomWelcome alloc]init];
                [joinChatroomMessage setId:[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].currentUserInfo.userId];
                [self sendMessage:joinChatroomMessage pushContent:nil success:nil error:nil];
                //                 [weakSelf.livePlayingManager startPlaying];
                if (self.model.liveMode == RCCRLiveModeHost) {
                    [self joinRoom:self.roomID completion:^(BOOL success) {
                        if (success) {
                            [[RCIMClient sharedRCIMClient] joinChatRoom:self.targetId messageCount:-1 success:^{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self addButtonBar];
                                    
                                });
                            } error:^(RCErrorCode status) {
                                
                            }];
                        }
                    }];
                } else {
                    
                    [self joinRoom:self.roomID url:self.model.liveUrl];
                }
            } error:^(RCErrorCode status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self alertErrorWithTitle:@"提示" message:@"加入聊天室失败" ok:@"知道了"];
                });
            }];
            
        });
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    [self.hostPortraitImgV setImage:[UIImage imageNamed:[NSString stringWithFormat:@"chatroom_0%@",self.model.hostPortrait]]];
    [self.hostNameLbl setText:self.model.hostName];
    
    //  获取数据,刷新界面
    //    for (int i = 0; i<1; i++) {
    //        RCCRAudienceModel *audienceModel = [[RCCRAudienceModel alloc] init];
    //        audienceModel.audienceName = [NSString stringWithFormat:@"观众%d号",i+1];
    //        audienceModel.audiencePortrait = [NSString stringWithFormat:@"audience%d",i+1];
    //        [self.audienceList addObject:audienceModel];
    //    }
    [self.hostInformationView setDataModel:self.model];
    [self.audienceListView setModelArray:self.audienceList];
    NSMutableArray *giftArr = [[NSMutableArray alloc] init];
    for (int i = 0; i<5; i++) {
        RCCRGiftModel *giftModel = [[RCCRGiftModel alloc] init];
        giftModel.giftImageName = [NSString stringWithFormat:@"GiftId_%d",(i)%5 + 1];
        giftModel.giftId = [NSString stringWithFormat:@"GiftId_%d",(i)%5 + 1];
        giftModel.giftName = [NSString stringWithFormat:@"gift%d",i];
        giftModel.giftPrice = (i + 1)*100;
        [giftArr addObject:giftModel];
    }
    [self.giftListView setModelArray:giftArr];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    //退出页面，弹幕停止
    [self.view stopDanmaku];
    [[RCCRManager sharedRCCRManager] setUserUnban];
}

/**
 *  注册监听Notification
 */
- (void)registerNotification {
    //注册接收消息
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didReceiveMessageNotification:)
     name:RCCRKitDispatchMessageNotification
     object:nil];
}

// 清理环境（退出聊天室并断开融云连接）
- (void)quitConversationViewAndClear {
    if ([self.model.pubUserId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"确认退出直播间吗" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
            [self quit];
        }];
        [alert addAction:action];
        [alert addAction:action1];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self quit];
    }
    
}
- (void)quit{
    if (self.conversationType == ConversationType_CHATROOM) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
            //            [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] setIsLogin:NO];
        });
        //退出聊天室
        RCChatroomUserQuit *quitMessage = [[RCChatroomUserQuit alloc] init];
        quitMessage.id = [RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].currentUserInfo.userId;
        quitMessage.senderUserInfo = [RCIMClient sharedRCIMClient].currentUserInfo;
        [self sendMessage:quitMessage pushContent:nil success:^(long messageId) {
            [self quitLiveRoom];
        } error:^(RCErrorCode nErrorCode, long messageId) {
            [self quitLiveRoom];
        }];
        
        
    }
}
- (void)quitLiveRoom{
    [[RCIMClient sharedRCIMClient] quitChatRoom:self.targetId
                                        success:^{
        
        NSLog(@"退出成功");
        //断开融云连接，如果你退出聊天室后还有融云的其他通讯功能操作，可以不用断开融云连接，否则断开连接后需要重新connectWithToken才能使用融云的功能
        //                                                [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] logoutRongCloud];
    } error:^(RCErrorCode status) {
        NSLog(@"退出失败:%@",@(status));
    }];
    
    if (self.model.liveMode == RCCRLiveModeHost) {
        if ([[RCIMClient sharedRCIMClient].currentUserInfo.userId isEqualToString:self.model.pubUserId]) {
            [[RCCRLiveHttpManager sharedManager] unpublish:self.roomID completion:^(BOOL success) {
                NSLog(@"取消主播资源成功？%@",@(success));
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                    //            [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] setIsLogin:NO];
                });
                // 主播退出
                [self.liveModuleManager quitRoom:self.roomID completion:^(BOOL isSuccess) {
                    NSLog(@"退出 RTC room 成功？%@",@(isSuccess));
                }];
            }];
        } else {
            // 主播退出
            [self.liveModuleManager quitRoom:self.roomID completion:^(BOOL isSuccess) {
                NSLog(@"退出 RTC room 成功？%@",@(isSuccess));
                
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
                //            [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] setIsLogin:NO];
            });
        }
        
        
    } else {
        
        //        // 观众退出
        [self.liveModuleManager quitLive:^(BOOL isSuccess, RCRTCCode code) {
            NSLog(@"退出 RTC Live 成功？%@",@(isSuccess));
            
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
            //            [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] setIsLogin:NO];
        });
    }
    
}
- (float)getIPhonexExtraBottomHeight {
    float height = 0;
    if (@available(iOS 11.0, *)) {
        height = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets].bottom;
    }
    return height;
}

#pragma mark <UIScrollViewDelegate,UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    if ([collectionView isEqual:self.portraitCollectionView]) {
        return self.audienceList.count;
    }
    return self.conversationDataRepository.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.portraitCollectionView]) {
        RCCRPortraitCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:portraitCollectionViewCellIndentifier forIndexPath:indexPath];
        RCCRAudienceModel *model = self.audienceList[indexPath.row];
        [cell setDataModel:model];
        return cell;
    }
    
    RCCRMessageModel *model =
    [self.conversationDataRepository objectAtIndex:indexPath.row];
    RCMessageContent *messageContent = model.content;
    RCCRMessageBaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ConversationMessageCollectionViewCell forIndexPath:indexPath];;
    if ([messageContent isMemberOfClass:[RCTextMessage class]] || [messageContent isMemberOfClass:[RCChatroomWelcome class]] || [messageContent isMemberOfClass:[RCChatroomFollow class]] || [messageContent isMemberOfClass:[RCChatroomLike class]] ||
        [messageContent isMemberOfClass:[RCChatroomStart class]] ||
        [messageContent isMemberOfClass:[RCChatroomUserBan class]] ||
        [messageContent isMemberOfClass:[RCChatroomUserUnBan class]] ||
        [messageContent isMemberOfClass:[RCChatroomUserBlock class]] ||
        [messageContent isMemberOfClass:[RCChatroomUserUnBlock class]] ||
        [messageContent isMemberOfClass:[RCChatroomNotification class]] ||
        [messageContent isMemberOfClass:[RCChatroomEnd class]] ||
        [messageContent isMemberOfClass:[RCChatroomUserQuit class]]){
        RCCRTextMessageCell *__cell = nil;
        NSString *indentifier = nil;
        if ([messageContent isMemberOfClass:[RCChatroomStart class]] ||
            [messageContent isMemberOfClass:[RCChatroomEnd class]]) {
            indentifier = startAndEndCellIndentifier;
        } else {
            indentifier = textCellIndentifier;
        }
        __cell = [collectionView dequeueReusableCellWithReuseIdentifier:indentifier forIndexPath:indexPath];
        [__cell setDataModel:model];
        cell = __cell;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.portraitCollectionView]) {
        return CGSizeMake(35,35);
    }
    RCCRMessageModel *model = self.conversationDataRepository[indexPath.row];
    if ([model.content isKindOfClass:[RCChatroomStart class]] || [model.content isKindOfClass:[RCChatroomEnd class]]) {
        return CGSizeMake(300,70);
    }
    if ([model.content isKindOfClass:[RCTextMessage class]]) {
        RCTextMessage *textMessage = model.content;
        NSString *localizedMessage = textMessage.content;
        RCUserInfo *userInfo = model.userInfo;
        NSString *userName = [userInfo.name stringByAppendingString:@"："];
        NSString *str =[NSString stringWithFormat:@"%@%@",userName,localizedMessage];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSAttributedString *string = [[NSAttributedString alloc]initWithString:str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18], NSParagraphStyleAttributeName:paragraphStyle}];
        
        CGSize size =  [string boundingRectWithSize:CGSizeMake(300.f, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
        if (size.height<40) {
            size.height = 40;
        } else {
            size.height += 20;
        }
        return CGSizeMake(300, size.height);
    }
    if ([model.content isKindOfClass:[RCChatRoomNotiAllMessage class]] || [model.content isKindOfClass:[RCChatRoomLiveCommand class]] ) {
        return CGSizeMake(300,12);
    }
    return CGSizeMake(300,40);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.portraitCollectionView]) {
        RCCRAudienceModel *model = self.audienceList[indexPath.row];
        [self audiencePotraitClick:model];
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return -14.f;
}

/**
 *  消息滚动到底部
 *
 *  @param animated 是否开启动画效果
 */
- (void)scrollToBottomAnimated:(BOOL)animated {
    if ([self.conversationMessageCollectionView numberOfSections] == 0) {
        return;
    }
    NSUInteger finalRow = MAX(0, [self.conversationMessageCollectionView numberOfItemsInSection:0] - 1);
    if (0 == finalRow) {
        return;
    }
    NSIndexPath *finalIndexPath =
    [NSIndexPath indexPathForItem:finalRow inSection:0];
    [self.conversationMessageCollectionView scrollToItemAtIndexPath:finalIndexPath
                                                   atScrollPosition:UICollectionViewScrollPositionTop
                                                           animated:animated];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 是否显示右下未读icon
    if (self.unreadNewMsgCount != 0) {
        [self checkVisiableCell];
    }
    
    //    if (scrollView.contentOffset.y < -5.0f) {
    //        [self.collectionViewHeader startAnimating];
    //    } else {
    //        [self.collectionViewHeader stopAnimating];
    //        _isLoading = NO;
    //    }
}

#pragma mark - RCCRInputBarControlDelegate

//  根据inputBar 回调来修改页面布局
- (void)onInputBarControlContentSizeChanged:(CGRect)frame withAnimationDuration:(CGFloat)duration andAnimationCurve:(UIViewAnimationCurve)curve {
    CGRect originFrame = _messageContentView.frame;
    __weak __typeof(&*self)weakSelf = self;
    //  目前只使用y值即可 -- 只修改messageContentView高度，让展示消息view和输入框随之移动
    [UIView animateWithDuration:duration animations:^{
        [UIView setAnimationCurve:curve];
        [weakSelf.messageContentView setFrame:CGRectMake(0, frame.origin.y - originFrame.size.height, originFrame.size.width, originFrame.size.height)];
        [UIView commitAnimations];
    }];
    
}

//  发送消息
- (void)onTouchSendButton:(NSString *)text {
    //判断是否禁言
    if ([RCCRManager sharedRCCRManager].isBan) {
        [self insertNotificationMessage:banNotifyContent];
    } else {
        [self touristSendMessage:text];
    }
}

- (void)touristSendMessage:(NSString *)text {
    if (self.isSendDanmaku) {
        //判断是否禁言
        if ([RCCRManager sharedRCCRManager].isBan) {
            [self insertNotificationMessage:banNotifyContent];
        } else {
            RCChatroomBarrage *barrageMessage = [[RCChatroomBarrage alloc] init];
            barrageMessage.content = text;
            [self showDanmaku:text userInfo:[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].currentUserInfo];
            [self sendMessage:barrageMessage pushContent:nil success:nil error:nil];
        }
        
    } else {
        RCTextMessage *rcTextMessage = [RCTextMessage messageWithContent:text];
        [self sendMessage:rcTextMessage pushContent:nil success:nil error:nil];
    }
}
-(void)didSelectAudience:(RCCRAudienceModel *)model index:(NSInteger)index{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setDefaultBottomViewStatus];
        [self.audienceList replaceObjectAtIndex:index withObject:model];
        [self.audienceListView setModelArray:self.audienceList];
        if (self.acceptUsers.count <= KMAXCOUNT) {
            
            RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:model.userId name:model.audienceName portrait:model.audiencePortrait];
            [self.acceptUsers addObject:userInfo];
            [self sendPrivateMessageWithTargetId:model.userId type:RCCRLiveCommandTypeInvite];
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlert:@"最多邀请六个人进行连麦"];
            });
        }
        
    });
}
- (void)sendPrivateMessageWithTargetId:(NSString *)targetId type:(RCCRLiveCommandType)type{
    RCChatRoomLiveCommand *command = [[RCChatRoomLiveCommand alloc] init];
    command.roomId = self.roomID;
    command.commandType = type;
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] sendMessage:(ConversationType_PRIVATE) targetId:targetId content:command pushContent:nil pushData:nil success:^(long messageId) {
        NSLog(@"给%@发送定向消息成功了",targetId);
    } error:^(RCErrorCode nErrorCode, long messageId) {
        NSLog(@"给%@发送定向消息失败了:%@",targetId,@(nErrorCode));
    }];
}
#pragma mark sendMessage/showMessage
/**
 发送消息
 
 @param messageContent 消息
 @param pushContent pushContent
 */
- (void)sendMessage:(RCMessageContent *)messageContent
        pushContent:(NSString *)pushContent
            success:(void (^)(long messageId))successBlock
              error:(void (^)(RCErrorCode nErrorCode, long messageId))errorBlock {
    if (_targetId == nil) {
        return;
    }
    messageContent.senderUserInfo = [RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].currentUserInfo;
    if (messageContent == nil) {
        return;
    }
    
    __weak typeof(&*self) __weakself = self;
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] sendMessage:self.conversationType targetId:self.targetId content:messageContent pushContent:pushContent pushData:nil success:^(long messageId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            RCMessage *message = [[RCMessage alloc] initWithType:__weakself.conversationType
                                                        targetId:__weakself.targetId
                                                       direction:MessageDirection_SEND
                                                       messageId:messageId
                                                         content:messageContent];
            message.content.senderUserInfo = [RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].currentUserInfo;
            //  过滤礼物消息，弹幕消息,退出聊天室消息不插入数据源中；
            if ([messageContent isMemberOfClass:[RCChatroomGift class]] || [messageContent isMemberOfClass:[RCChatroomBarrage class]] || [messageContent isMemberOfClass:[RCChatroomUserQuit class]]) {
                if ([messageContent isMemberOfClass:[RCChatroomBarrage class]]) {
                    [__weakself.inputBar clearInputView];
                }
            } else {
                message.senderUserId = [RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].currentUserInfo.userId;
                [__weakself appendAndDisplayMessage:message];
                [__weakself.inputBar clearInputView];
            }
        });
        if (successBlock) {
            successBlock(messageId);
        }
    } error:^(RCErrorCode nErrorCode, long messageId) {
        if (nErrorCode == RC_CHATROOM_NOT_EXIST) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self alertErrorWithTitle:@"提示" message:@"1 小时内无人讲话，聊天已被解散，请退出后重进。" ok:@"知道了"];
            });
            
        }
        [__weakself.inputBar clearInputView];
        NSLog(@"发送失败，errorcode is: %ld",(long)nErrorCode);
        if (errorBlock) {
            errorBlock(nErrorCode, messageId);
        }
    }];
    
}

/**
 *  接收到消息的回调
 */
- (void)didReceiveMessageNotification:(NSNotification *)notification {
    __block RCMessage *rcMessage = notification.object;
    RCCRMessageModel *model = [[RCCRMessageModel alloc] initWithMessage:rcMessage];
    model.userInfo = rcMessage.content.senderUserInfo;
    
    if (model.conversationType == self.conversationType &&
        [model.targetId isEqual:self.targetId]) {
        __weak typeof(&*self) __blockSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([model.content isMemberOfClass:[RCChatroomUserQuit class]] && [model.senderUserId isEqualToString:self.model.pubUserId]) {
                [[RCRTCEngine sharedInstance] leaveRoom:self.model.roomId completion:^(BOOL isSuccess, RCRTCCode code) {
                    
                }];
                if (self.alert) {
                    [self.alert dismissViewControllerAnimated:NO completion:nil];
                }
                self.alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"本次直播结束!" preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
                    [self quitConversationViewAndClear];
                }];
                [self.alert addAction:action];
                [self presentViewController:self.alert animated:YES completion:nil];
            }
            //  对礼物消息,赞消息进行拦截，展示动画，不插入到数据源中,对封禁消息，弹出alert
            if (rcMessage) {
                if ([rcMessage.content isMemberOfClass:[RCChatroomGift class]])  {
                    RCChatroomGift *giftMessage = (RCChatroomGift *)rcMessage.content;
                    RCCRGiftModel *model = [[RCCRGiftModel alloc] initWithMessage:giftMessage];
                    [__blockSelf presentGiftAnimation:model userInfo:giftMessage.senderUserInfo];
                    RCCRLiveModel *liveModel = __blockSelf.hostInformationView.hostModel;
                    liveModel.giftAmount += giftMessage.number;
                    [__blockSelf.hostInformationView setDataModel:liveModel];
                    return ;
                } else if ([rcMessage.content isMemberOfClass:[RCChatroomLike class]]) {
                    RCChatroomLike *likeMessage = (RCChatroomLike *)rcMessage.content;
                    for (int i = 0;i < likeMessage.counts ; i++) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1*i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [__blockSelf presentLikeMessageAnimation:likeMessage];
                        });
                    }
                    RCCRLiveModel *liveModel = __blockSelf.hostInformationView.hostModel;
                    liveModel.praiseAmount += likeMessage.counts;
                    [__blockSelf.hostInformationView setDataModel:liveModel];
                } else if ([rcMessage.content isMemberOfClass:[RCChatroomBarrage class]]) {
                    //  处理是否发送弹幕消息
                    if([NSThread isMainThread]){
                        [__blockSelf sendReceivedDanmaku:rcMessage];
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [__blockSelf sendReceivedDanmaku:rcMessage];
                        });
                    }
                    return;
                } else if ([rcMessage.content isMemberOfClass:[RCChatroomWelcome class]]) {
                    //  过滤自己发送的欢迎消息
                    if ([rcMessage.senderUserId isEqualToString:[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].currentUserInfo.userId]) {
                        return;
                    }
                } else if ([rcMessage.content isMemberOfClass:[RCChatroomFollow class]]) {
                    RCCRLiveModel *hostModel = __blockSelf.hostInformationView.hostModel;
                    hostModel.fansAmount++;
                    [self.hostInformationView setDataModel:hostModel];
                } else if ([rcMessage.content isMemberOfClass:[RCChatroomUserBlock class]]) {
                    RCChatroomUserBlock *blockMessage = (RCChatroomUserBlock*)rcMessage.content;
                    if ([blockMessage.id isEqualToString:[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].currentUserInfo.userId]) {
                        [__blockSelf presentAlert:@"您被管理员踢出聊天室"];
                        [[RCCRUtilities instance] blockRoom:__blockSelf.model.roomId duration:blockMessage.duration];
                        [self showAlert:@"您已被踢出直播间"];
                        [self quitConversationViewAndClear];
                        
                    }
                } else if ([rcMessage.content isMemberOfClass:[RCChatRoomNotiAllMessage class]]){
                    if (self.model.liveMode == RCCRLiveModeHost) {
                        RCChatRoomNotiAllMessage *message = (RCChatRoomNotiAllMessage *)rcMessage.content;
                        self.allLiveUsers = message.userInfos.mutableCopy;
                        [self.remoteView hostNotiUpdateNames:self.allLiveUsers.copy];
                    }
                    
                }
                
                NSDictionary *leftDic = notification.userInfo;
                if (leftDic && [leftDic[@"left"] isEqual:@(0)]) {
                    __blockSelf.isNeedScrollToButtom = YES;
                }
                [__blockSelf appendAndDisplayMessage:rcMessage];
                UIMenuController *menu = [UIMenuController sharedMenuController];
                menu.menuVisible=NO;
                //如果消息不在最底部，收到消息之后不滚动到底部，加到列表中只记录未读数
                if (![__blockSelf isAtTheBottomOfTableView]) {
                    __blockSelf.unreadNewMsgCount ++ ;
                    [__blockSelf updateUnreadMsgCountLabel];
                }
            }
        });
    } else if (model.conversationType == ConversationType_PRIVATE ){
        RCMessageContent *content = rcMessage.content;
        RCChatRoomLiveCommand *liveCommand;
        if ([content isKindOfClass:[RCChatRoomLiveCommand class]]) {
            liveCommand = (RCChatRoomLiveCommand *)content;
        }
        if (![liveCommand.roomId isEqualToString:self.model.roomId]) {
            return;
        }
        if (self.model.liveMode == RCCRLiveModeAudience) {
            if (liveCommand && liveCommand.commandType == RCCRLiveCommandTypeInvite) {
                // 收到邀请
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.alert) {
                        [self.alert dismissViewControllerAnimated:NO completion:nil];
                    }
                    self.alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"\"%@\" 邀请您上麦",model.userInfo.name] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *action = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                        [self reject:model.userInfo.userId];
                    }];
                    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self accept:model.userInfo.userId];
                    }];
                    [self.alert addAction:action];
                    [self.alert addAction:action1];
                    [self presentViewController:self.alert animated:YES completion:nil];
                });
            }
            
        } else if (self.model.liveMode == RCCRLiveModeHost && (liveCommand.commandType == RCCRLiveCommandTypeAccept || liveCommand.commandType == RCCRLiveCommandTypeReject)){
            if (liveCommand) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (liveCommand.commandType == RCCRLiveCommandTypeReject) {
                        RCUserInfo *userInfo = model.userInfo;
                        for (RCUserInfo *user in self.acceptUsers) {
                            if ([userInfo.userId isEqualToString:user.userId]) {
                                [self.acceptUsers removeObject:user];
                                [self.audienceListView reloadInvitedStateWithUserId:userInfo.userId];
                                break;
                            }
                        }
                    }
                    
                    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"\"%@\" %@ 了您的邀请",model.userInfo.name,liveCommand.commandType == RCCRLiveCommandTypeReject?@"拒绝":@"接受"] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    [controller addAction:action1];
                    [self presentViewController:controller animated:YES completion:nil];
                });
                
            }
            
        }
    }
}
- (void)becomeHost{
    // 先取消观众身份
    [self.liveModuleManager quitLive:^(BOOL isSuccess, RCRTCCode code) {
        NSLog(@"退出观众身份成功？%@",@(isSuccess));
        dispatch_async(dispatch_get_main_queue(), ^{
            self.remoteVideoView.hidden = YES;
            self.localView.hidden = NO;
            self.model.liveMode = RCCRLiveModeHost;
            [self joinRoom:self.roomID completion:^(BOOL success) {
                [self.buttonBar reloadData:(self.model.liveMode == RCCRLiveModeHost ? RCCRButtonBarTypeHost : RCCRButtonBarTypeNormal)];
            }];
        });
        
    }];
}
- (void)reject:(NSString *)targetId{
    [self sendPrivateMessageWithTargetId:targetId type:RCCRLiveCommandTypeReject];
}
- (void)accept:(NSString *)targetId{
    [self sendPrivateMessageWithTargetId:targetId type:RCCRLiveCommandTypeAccept];
    [self becomeHost];
}

/**
 *  将消息加入本地数组
 */
- (void)appendAndDisplayMessage:(RCMessage *)rcMessage {
    if (!rcMessage) {
        return;
    }
    RCCRMessageModel *model = [[RCCRMessageModel alloc] initWithMessage:rcMessage];
    model.userInfo = rcMessage.content.senderUserInfo;
    if (!model.userInfo) {
        model.userInfo = [[RCCRManager sharedRCCRManager]getUserInfo:rcMessage.senderUserId];
    }
    RCMessageContent *content = rcMessage.content;
    RCUserInfo *userInfo = content.senderUserInfo;
    if ([content isKindOfClass:[RCChatroomWelcome class]] && ![userInfo.userId isEqualToString:[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].currentUserInfo.userId]) {
        RCCRAudienceModel *audienceModel = [[RCCRAudienceModel alloc] init];
        audienceModel.audienceName = userInfo.name;
        audienceModel.audiencePortrait = [NSString stringWithFormat:@"audience%@",userInfo.portraitUri];
        audienceModel.userId = userInfo.userId;;
        [self.audienceList addObject:audienceModel];
        [self.audienceListView setModelArray:self.audienceList];
        [self.portraitCollectionView reloadData];
        if (self.model.liveMode == RCCRLiveModeHost) {
            [self.remoteView updateNamesWithWelcome:self.audienceList];
        }
        
    } else if([content isKindOfClass:[RCChatroomUserQuit class]]){
        for (RCCRAudienceModel *model  in self.audienceList) {
            if ([model.userId isEqualToString:userInfo.userId]) {
                [self.audienceList removeObject:model];
                break;
            }
        }
        [self.audienceListView setModelArray:self.audienceList];
        [self.portraitCollectionView reloadData];
    }
    if ([self appendMessageModel:model]) {
        NSIndexPath *indexPath =
        [NSIndexPath indexPathForItem:self.conversationDataRepository.count - 1
                            inSection:0];
        if ([self.conversationMessageCollectionView numberOfItemsInSection:0] !=
            self.conversationDataRepository.count - 1) {
            return;
        }
        //  view刷新
        [self.conversationMessageCollectionView
         insertItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        if ([self isAtTheBottomOfTableView] || self.isNeedScrollToButtom) {
            [self scrollToBottomAnimated:YES];
            self.isNeedScrollToButtom=NO;
        }
    }
    return;
}

- (void)sendReceivedDanmaku:(RCMessage *)message {
    if ([message.content isMemberOfClass:[RCChatroomBarrage class]]){
        RCChatroomBarrage *danmakuMessage = (RCChatroomBarrage *)message.content;
        [self showDanmaku:danmakuMessage.content userInfo:danmakuMessage.senderUserInfo];
    }
}

/**
 *  判断消息是否在collectionView的底部
 *
 *  @return 是否在底部
 */
- (BOOL)isAtTheBottomOfTableView {
    if (self.conversationMessageCollectionView.contentSize.height <= self.conversationMessageCollectionView.frame.size.height) {
        return YES;
    }
    if(self.conversationMessageCollectionView.contentOffset.y +200 >= (self.conversationMessageCollectionView.contentSize.height - self.conversationMessageCollectionView.frame.size.height)) {
        return YES;
    }else{
        return NO;
    }
}

/**
 *  更新底部新消息提示显示状态
 */
- (void)updateUnreadMsgCountLabel{
    if (self.unreadNewMsgCount == 0) {
        //        self.unreadButtonView.hidden = YES;
    }
    else{
        //        self.unreadButtonView.hidden = NO;
        //        self.unReadNewMessageLabel.text = @"底部有新消息";
    }
}

/**
 *  检查是否更新新消息提醒
 */
- (void) checkVisiableCell{
    NSIndexPath *lastPath = [self getLastIndexPathForVisibleItems];
    if (lastPath.row >= self.conversationDataRepository.count - self.unreadNewMsgCount || lastPath == nil || [self isAtTheBottomOfTableView] ) {
        self.unreadNewMsgCount = 0;
        [self updateUnreadMsgCountLabel];
    }
}

/**
 *  获取显示的最后一条消息的indexPath
 *
 *  @return indexPath
 */
- (NSIndexPath *)getLastIndexPathForVisibleItems
{
    NSArray *visiblePaths = [self.conversationMessageCollectionView indexPathsForVisibleItems];
    if (visiblePaths.count == 0) {
        return nil;
    }else if(visiblePaths.count == 1) {
        return (NSIndexPath *)[visiblePaths firstObject];
    }
    NSArray *sortedIndexPaths = [visiblePaths sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSIndexPath *path1 = (NSIndexPath *)obj1;
        NSIndexPath *path2 = (NSIndexPath *)obj2;
        return [path1 compare:path2];
    }];
    return (NSIndexPath *)[sortedIndexPaths lastObject];
}

#pragma mark sendDanmaku
- (void)showDanmaku:(NSString *)text userInfo:(RCUserInfo *)userInfo {
    if(!text || text.length == 0){
        return;
    }
    RCDDanmaku *danmaku = [[RCDDanmaku alloc]init];
    danmaku.contentStr = [[NSAttributedString alloc]initWithString:text attributes:@{NSForegroundColorAttributeName : kRandomColor}];
    //    RCCRAudienceModel *audienceModel = [[RCCRAudienceModel alloc] init];
    
    //    audienceModel.audienceName = currentUserInfo.name;
    //    audienceModel.audiencePortrait = currentUserInfo.portraitUri;
    danmaku.model = userInfo;
    [self.liveView sendDanmaku:danmaku];
}

- (void)sendCenterDanmaku:(NSString *)text {
    if(!text || text.length == 0){
        return;
    }
    RCDDanmaku *danmaku = [[RCDDanmaku alloc]init];
    danmaku.contentStr = [[NSAttributedString alloc]initWithString:text attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:218.0/255 green:178.0/255 blue:115.0/255 alpha:1]}];
    danmaku.position = RCDDanmakuPositionCenterTop;
    [self.liveView sendDanmaku:danmaku];
}

#pragma mark - gesture and button action
- (void)resetBottomGesture:
(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self setDefaultBottomViewStatus];
    }
}

- (void)setDefaultBottomViewStatus {
    [self.inputBar setInputBarStatus:RCCRBottomBarStatusDefault];
    [self.inputBar setHidden:YES];
    __weak __typeof(&*self)weakSelf = self;
    CGFloat height = self.view.bounds.size.height;
    if (!self.hostInformationView.hidden) {
        CGRect frame = self.hostInformationView.frame;
        frame.origin.y = height;
        [UIView animateWithDuration:0.2 animations:^{
            [weakSelf.hostInformationView setFrame:frame];
        } completion:^(BOOL finished) {
            [weakSelf.hostInformationView setHidden:YES];
        }];
    }
    if (!self.giftListView.hidden) {
        CGRect frame = self.giftListView.frame;
        frame.origin.y = height;
        [UIView animateWithDuration:0.2 animations:^{
            [weakSelf.giftListView setFrame:frame];
        } completion:^(BOOL finished) {
            [weakSelf.giftListView setHidden:YES];
        }];
    }
    if (!self.audienceListView.hidden) {
        CGRect frame = self.giftListView.frame;
        frame.origin.y = height;
        [UIView animateWithDuration:0.2 animations:^{
            [weakSelf.audienceListView setFrame:frame];
        } completion:^(BOOL finished) {
            [weakSelf.audienceListView setHidden:YES];
        }];
    }
}

/**
 *  如果当前会话没有这个消息id，把消息加入本地数组
 */
- (BOOL)appendMessageModel:(RCCRMessageModel *)model {
    
    if (!model.content) {
        return NO;
    }
    //这里可以根据消息类型来决定是否显示，如果不希望显示直接return NO
    
    //数量不可能无限制的大，这里限制收到消息过多时，就对显示消息数量进行限制。
    //用户可以手动下拉更多消息，查看更多历史消息。
    if (self.conversationDataRepository.count>100) {
        //                NSRange range = NSMakeRange(0, 1);
        RCCRMessageModel *message = self.conversationDataRepository[0];
        [[RCIMClient sharedRCIMClient]deleteMessages:@[@(message.messageId)]];
        [self.conversationDataRepository removeObjectAtIndex:0];
        [self.conversationMessageCollectionView reloadData];
    }
    
    [self.conversationDataRepository addObject:model];
    return YES;
}

/**
 点击主播头像
 */
- (void)hostPotraitClick:(id)sender {
    if (!self.hostInformationView.hidden) {
        return;
    }
    CGRect frame = self.hostInformationView.frame;
    frame.origin.y -= frame.size.height;
    [self.hostInformationView setHidden:NO];
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        [weakSelf.hostInformationView setFrame:frame];
    } completion:nil];
}

/**
 点击观众头像
 */
- (void)audiencePotraitClick:(RCCRAudienceModel *)model {
    CGRect frame = self.oriFrame;
    frame.origin.y -= frame.size.height;
    [self.audienceListView setHidden:NO];
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        [weakSelf.audienceListView setFrame:frame];
    } completion:nil];
}

/**
 返回按钮事件
 */
- (void)backButtonItemPressed:(id)sender {
    [self quitConversationViewAndClear];
}

/**
 发言按钮事件
 */
- (void)commentBtnPressed:(id)sender {
    //  判断是否登录了
    if ([[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] isLogin]) {
        //判断是否禁言
        if ([RCCRManager sharedRCCRManager].isBan) {
            [self insertNotificationMessage:banNotifyContent];
        } else {
            [_inputBar setHidden:NO];
            [_inputBar setInputBarStatus:RCCRBottomBarStatusKeyboard];
            self.isSendDanmaku = NO;
        }
    } else {
        
    }
}

/**
 发送弹幕
 */
- (void)danmakuBtnPressed:(id)sender {
    if ([[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] isLogin]) {
        //判断是否禁言
        if ([RCCRManager sharedRCCRManager].isBan) {
            [self insertNotificationMessage:banNotifyContent];
        } else {
            [_inputBar setHidden:NO];
            [_inputBar setInputBarStatus:RCCRBottomBarStatusKeyboard];
            self.isSendDanmaku = YES;
        }
    } else {
        
    }
}

/**
 送礼物按钮事件
 */
- (void)giftBtnPressed:(id)sender {
    if ([self.model.pubUserId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        return;
    }
    if ([[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] isLogin]) {
        CGRect frame = self.giftListView.frame;
        frame.origin.y -= frame.size.height;
        [self.giftListView setHidden:NO];
        __weak __typeof(&*self)weakSelf = self;
        [UIView animateWithDuration:0.2 animations:^{
            [weakSelf.giftListView setFrame:frame];
        } completion:nil];
    } else {
        CGRect frame = self.hostInformationView.frame;
        frame.origin.y = self.view.bounds.size.height;
        
        __weak __typeof(&*self)weakSelf = self;
        [UIView animateWithDuration:0.2 animations:^{
            [weakSelf.hostInformationView setFrame:frame];
        } completion:^(BOOL finished) {
            [weakSelf.hostInformationView setHidden:YES];
            
        }];
    }
}

/**
 点赞
 */
- (void)praiseBtnPressed:(id)sender {
    if ([self.model.pubUserId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        return;
    }
    if ([[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] isLogin]) {
        NSTimeInterval currentTime =  [[NSDate date] timeIntervalSince1970];
        __weak __typeof(&*self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.21 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([[NSDate date] timeIntervalSince1970] - self.lastClickPraiseTime >= 0.2) {
                
                RCChatroomLike *praiseSendMessage = [[RCChatroomLike alloc] init];
                praiseSendMessage.counts = clickPraiseBtnTimes;
                [weakSelf sendMessage:praiseSendMessage pushContent:nil success:nil error:nil];
                RCCRLiveModel *liveModel = weakSelf.hostInformationView.hostModel;
                liveModel.praiseAmount += clickPraiseBtnTimes;
                [weakSelf.hostInformationView setDataModel:liveModel];
                clickPraiseBtnTimes = 0;
            }
        });
        RCChatroomLike *praiseMessage = [[RCChatroomLike alloc] init];
        clickPraiseBtnTimes++;
        self.lastClickPraiseTime = currentTime;
        [self presentLikeMessageAnimation:praiseMessage];
    } else {
        CGRect frame = self.hostInformationView.frame;
        frame.origin.y = self.view.bounds.size.height;
        
        __weak __typeof(&*self)weakSelf = self;
        [UIView animateWithDuration:0.2 animations:^{
            [weakSelf.hostInformationView setFrame:frame];
        } completion:^(BOOL finished) {
            [weakSelf.hostInformationView setHidden:YES];
            
        }];
    }
}
- (void)settingBtnClicked:(id)sender{
    RCCRSettingViewController *setting = [[RCCRSettingViewController alloc] init];
    setting.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    __weak typeof(self)weakSelf = self;
    [setting setClickSaveBlock:^(RCCRLiveLayoutModel *model) {
        NSLog(@"layout type:%@",@(model.layoutType));
        NSLog(@"layout x:%@",@(model.x));
        NSLog(@"layout h:%@",@(model.height));
        NSLog(@"layout w:%@",@(model.width));
        NSLog(@"layout crop:%@",@(model.customCrop));
        weakSelf.settingModel.layoutModel = model;
        [weakSelf.liveModuleManager setMixStreamConfig:model];
    }];
    setting.settingModel = self.settingModel;
    [self.navigationController presentViewController:setting animated:NO completion:nil];
}
/**
 赞动画
 
 @param likeMessage 赞消息
 */
- (void)presentLikeMessageAnimation:(RCChatroomLike *)likeMessage {
    CGRect startRect = [self.view convertRect:self.praiseBtn.frame fromView:self.bottomBtnContentView];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = startRect;
    imageView.image = [UIImage imageNamed:@"heartIcon"];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.clipsToBounds = YES;
    [self.view addSubview:imageView];
    [self.view insertSubview:imageView atIndex:1];
    //  随机数来决定动画过程
    CGFloat startX = round(random() % 200);
    CGFloat scale = round(random() % 2) + 1.0;
    CGFloat speed = 1 / round(random() % 900) + 0.6;
    int imageName = round(random() % 2);
    NSLog(@"%.2f - %.2f -- %d",startX,scale,imageName);
    
    [UIView beginAnimations:nil context:(__bridge void *_Nullable)(imageView)];
    [UIView setAnimationDuration:7 * speed];
    
    imageView.image = [UIImage imageNamed:@"heartIcon"];
    imageView.frame = CGRectMake(self.view.bounds.size.width - startX, -100, 35 * scale, 35 * scale);
    
    [UIView setAnimationDidStopSelector:@selector(onAnimationComplete:finished:context:)];
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}

- (void)onAnimationComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    //  动画结束移除控件
    UIImageView *imageView = (__bridge UIImageView *)(context);
    [imageView removeFromSuperview];
}

/**
 拦截加在整个背景view上的点击手势
 
 @param gestureRecognizer UIGestureRecognizer
 @param touch UITouch
 @return BOOL
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    NSLog(@"view class is %@",[touch.view class]);
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"] || [NSStringFromClass([touch.view class]) isEqualToString:@"RCCRgiftListView"] || [NSStringFromClass([touch.view class]) isEqualToString:@"GLKView"]|| [NSStringFromClass([touch.view class]) isEqualToString:@"RCRTCLocalVideoView"]) {
        if ([NSStringFromClass([touch.view class]) isEqualToString:@"RCRTCLocalVideoView"] || [NSStringFromClass([touch.view class]) isEqualToString:@"GLKView"]) {
            [self setDefaultBottomViewStatus];
        }
        
        return NO;
    }
    //在view中点击的坐标
    CGPoint touchPoint = [touch locationInView:self.view];
    //判断点击的坐标是否在限制的控件的范围内
    CGRect portraitCollectionViewRect = [self.view convertRect:self.portraitCollectionView.frame fromView:self.topContentView];
    bool value = CGRectContainsPoint(self.hostInformationView.frame, touchPoint) || CGRectContainsPoint(portraitCollectionViewRect, touchPoint)  || CGRectContainsPoint(self.giftListView.frame, touchPoint);
    
    if (value) {
        return NO;
    }
    return YES;
}
- (void)alertErrorWithTitle:(NSString *)title message:(NSString *)message ok:(NSString *)ok{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action = [UIAlertAction actionWithTitle:ok style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:action];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    });
    
}
#pragma mark - RTC
- (void)joinRoom:(NSString *)roomId completion:(void (^)(BOOL success))completion{
    [self.liveModuleManager startCapture];
    [[RCRTCEngine sharedInstance].defaultVideoStream setVideoView:self.localView];
    [self.liveModuleManager joinRoom:roomId completion:^(BOOL isSuccess,NSInteger code, RCRTCRoom * _Nullable room) {
        if (isSuccess) {
            NSLog(@"加入直播间成功");
            NSMutableArray *arr = [NSMutableArray array];
            NSMutableArray *videoArr = [NSMutableArray array];
            // 试图先画上
            for (RCRTCRemoteUser *user in room.remoteUsers) {
                for (RCRTCInputStream *stream in user.remoteStreams) {
                    [arr addObject:stream];
                    if (stream.mediaType == RTCMediaTypeVideo) {
                        
                        RCCRRemoteModel *model = [[RCCRRemoteModel alloc] init];
                        model.inputStream = stream;
                        for (RCUserInfo *userInfo in self.allLiveUsers) {
                            if ([userInfo.userId isEqualToString:stream.userId]) {
                                model.userName = userInfo.name;
                                break;
                            }
                        }
                        [videoArr addObject:model];
                        
                    }
                }
            }
            [self.remoteView setDataSources:videoArr];
            // 后请求
            if (arr.count > 0) {
                // 拉流
                [self.liveModuleManager subscribeStreams:arr completion:^(BOOL subscribeSuccess,RCRTCCode desc) {
                    if (!subscribeSuccess) {
                        [self alertErrorWithTitle:@"错误" message:[NSString stringWithFormat:@"拉流失败:%@",@(desc)] ok:@"ok"];
                    } else {
                        
                    }
                }];
            }
            // 推流
            [self.liveModuleManager publishDefaultStreams:^(BOOL publishSuccess ,RCRTCCode desc, RCRTCLiveInfo * _Nullable liveHostModel) {
                if (publishSuccess) {
                    self.localView.hidden = NO;
                    if ([[RCIMClient sharedRCIMClient].currentUserInfo.userId isEqualToString:self.model.pubUserId]) {
                        [[RCCRLiveHttpManager sharedManager] publish:roomId roomName:self.roomName liveUrl:liveHostModel.liveUrl cover:self.model.cover completion:^(BOOL success , NSInteger code) {
                            NSLog(@"主播发布资源成功？%@",@(success));
                            if (code == 5) {
                                if (completion) {
                                    completion(NO);
                                }
                                [self.liveModuleManager quitRoom:self.roomID completion:^(BOOL isSuccess) {
                                    NSLog(@"退出 RTC room 成功？%@",@(isSuccess));
                                }];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"房间名称重复，请重新创建直播间！" preferredStyle:(UIAlertControllerStyleAlert)];
                                    UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
                                        [self quit];
                                        
                                    }];
                                    [alert addAction:action];
                                    [self presentViewController:alert animated:YES completion:nil];
                                });
                            } else {
                                
                                if (completion) {
                                    completion(YES);
                                }
                            }
                        }];
                    } else {
                        [[RCRTCEngine sharedInstance].defaultVideoStream setVideoView:self.localView];
                        [self.liveModuleManager startCapture];
                        
                        if (completion) {
                            completion(YES);
                        }
                    }
                    
                } else {
                    if (completion) {
                        completion(YES);
                    }
                    [self alertErrorWithTitle:@"错误" message:[NSString stringWithFormat:@"推流失败:%@",@(desc)] ok:@"ok"];
                }
            }];
            
        } else {
            [self alertErrorWithTitle:@"错误" message:[NSString stringWithFormat:@"加入直播间失败:%@",@(code)] ok:@"ok"];
            self.localView.hidden = YES;
        }
    }];
}
- (void)startPublishVideoFile{
    RCRTCVideoStreamConfig *param = [[RCRTCVideoStreamConfig alloc] init];
    param.videoSizePreset = RCRTCVideoSizePreset640x360;
    NSString *tag = @"RongRTCFileVideo";
    self.fileStream = [[RCRTCVideoOutputStream alloc] initVideoOutputStreamWithTag:tag];
    [self.fileStream setVideoConfig:param];
    __weak typeof(self)weakSelf = self;
    [self.liveModuleManager publishAVStream:self.fileStream completiom:^(BOOL isSuccess, RCRTCCode desc) {
        __strong typeof(self)strongSelf = weakSelf;
        if (desc == RCRTCCodeSuccess) {
            [RCActiveWheel showPromptHUDAddedTo:self.view text:@"发布成功"];
        }
        else{
            [RCActiveWheel showPromptHUDAddedTo:self.view text:@"发布失败"];
        }
        RCCRRemoteModel *model = [[RCCRRemoteModel alloc] init];
        model.inputStream = strongSelf.fileStream;
        model.userName =  @"视频文件";
        self.fileModel = model;
        [self.remoteView pushBackDatas:@[model]];
        strongSelf.fileCapture = [[RCCRFileCapture alloc]init];
        strongSelf.fileCapture.delegate = self;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"video_demo2_low" ofType:@"mp4"];
        [strongSelf.fileCapture startCapturingFromFilePath:path ];
    }];
}
- (void)stopPublishVideoFile{
    [self.fileCapture stopCapture];
    self.fileCapture = nil;
    [self.liveModuleManager unpublishAVStream:self.fileStream completiom:^(BOOL isSuccess, RCRTCCode desc) {
        [self.remoteView deleteDataWithUserIds:@[self.fileModel.inputStream.userId]];
    }];
    self.fileStream = nil;
    
}
- (void)didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    [self.fileStream write:sampleBuffer error:nil];
    CFRelease(sampleBuffer);
}
-(void)didReadCompleted{
    RCCRRemoteViewCellCollectionViewCell *cell = [self.remoteView cellWithModel:self.fileModel];
    [(RCRTCLocalVideoView *)(cell.remoteView) flushVideoView];
}
- (void)joinRoom:(NSString *)roomId url:(NSString *)url{
    NSLog(@"观众进来了");
    [[RCRTCEngine sharedInstance] useSpeaker:YES];

    [self.liveModuleManager joinLive:self.model.liveUrl completion:^(RCRTCCode desc, RCRTCInputStream * _Nullable inputStream) {
        self.localView.hidden = NO;
        if (desc == RCRTCCodeSuccess) {
            self.remoteVideoView.hidden = NO;
            self.localView.hidden = YES;
            if (inputStream.mediaType == RTCMediaTypeVideo) {
                [(RCRTCVideoInputStream *)inputStream setVideoView:self.remoteVideoView];
            }
            
        } else {
            [self alertErrorWithTitle:@"错误" message:[NSString stringWithFormat:@"观看直播失败:%@",@(desc)] ok:@"ok"];
            self.localView.hidden = YES;
        }
    }];
}

-(void)didPublishStreams:(NSArray<RCRTCInputStream *> *)streams{
    if (self.model.liveMode == RCCRLiveModeHost) {
        [self.liveModuleManager subscribeStreams:streams completion:^(BOOL isSuccess , RCRTCCode desc) {
            if (isSuccess) {
                NSMutableArray *arr = [NSMutableArray array];
                for (RCRTCInputStream *stream in streams) {
                    if (stream.mediaType == RTCMediaTypeVideo) {
                        @autoreleasepool{
                            RCCRRemoteModel *model = [[RCCRRemoteModel alloc] init];
                            model.inputStream = stream;
                            for (RCCRAudienceModel *userInfo in self.audienceList) {
                                if ([userInfo.userId isEqualToString:stream.userId]) {
                                    model.userName = userInfo.audienceName;
                                    break;
                                }
                            }
                            if (!model.userName) {
                                for (RCUserInfo *userInfo in self.allLiveUsers) {
                                    if ([userInfo.userId isEqualToString:stream.userId]) {
                                        model.userName = userInfo.name;
                                        break;
                                    }
                                }
                            }
                            [arr addObject:model];
                        }
                    }
                }
                [self.remoteView pushBackDatas:arr];
            } else {
                [self alertErrorWithTitle:@"错误" message:[NSString stringWithFormat:@"拉流失败:%@",@(desc)] ok:@"ok"];
            }
        }];
        
    }
}
-(void)didJoinUser:(RCRTCRemoteUser *)user
{
    RCChatRoomNotiAllMessage *message = [[RCChatRoomNotiAllMessage alloc] init];
    message.userInfos = self.acceptUsers.mutableCopy;
    [self sendMessage:message pushContent:nil success:^(long messageId) {
        NSLog(@"发送通知消息成功");
    } error:^(RCErrorCode nErrorCode, long messageId) {
        NSLog(@"发送通知消息失败");
    }];
}
-(void)didLeaveUser:(RCRTCRemoteUser *)user{
    @synchronized (self) {
        NSLog(@"did leave user : %@",user.userId);
        NSArray *usersIndexPaths = [self.remoteView deleteDataWithUserIds:@[user.userId]];
        RCCRRemoteModel *model = usersIndexPaths.firstObject;
        if (self.localIsRemote == YES && [model isEqual:self.selectCell.remoteModel]) {
            self.localView.frame = self.localViewFrame;
            self.localView.fillMode = RCRTCVideoFillModeAspectFill;
            [self.liveView addSubview:self.localView];
        }
        if ([model isEqual:self.selectCell.remoteModel]) {
            self.selectCell = nil;
        }
        for (RCUserInfo *userinf in self.acceptUsers) {
            if ([user.userId isEqualToString:userinf.userId]) {
                [self.acceptUsers removeObject:userinf];
                break;
            }
        }
    }
}
-(void)remoteUsersIsNull{
    // 远端用户也没有，本地视频文件也没有
    if (self.fileModel == nil) {
        self.localView.hidden = NO;
        self.remoteVideoView.hidden = YES;
        self.localView.frame = self.localViewFrame;
        self.localView.fillMode = RCRTCVideoFillModeAspectFill;
        [self.liveView addSubview:self.localView];
        self.selectModel = nil;
        self.selectIndexPath = nil;
    }
}
-(void)didUnpublishStreams:(NSArray<RCRTCInputStream *> *)streams{
    [self.remoteView deleteDataWithStreams:streams];
}

-(void)didSelectCell:(RCCRRemoteViewCellCollectionViewCell *)cell model:(RCCRRemoteModel *)model indexPath:(NSIndexPath *)indexPath{
    if (self.selectCell) {
        if ([self.selectModel isEqual:cell.remoteModel]) {
            if (self.localIsRemote) {
                [self setRemoteIsLocal:cell indexPath:indexPath];
            } else {
                [self setLocalIsRemote:cell indexPath:indexPath];
            }
            [self setSelectCell:cell indexPath:indexPath];
        } else {
            if (self.localIsRemote) {
                [self.selectCell addRemoteVideoView:self.selectCell.remoteView];
            }
            [self setLocalIsRemote:cell indexPath:indexPath];
        }
    } else {
        [self setLocalIsRemote:cell indexPath:indexPath];
    }
    
}
- (void)setRemoteIsLocal:(RCCRRemoteViewCellCollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath{
    [cell addRemoteVideoView:cell.remoteView];
    self.localView.frame = self.localViewFrame;
    self.localView.fillMode = RCRTCVideoFillModeAspectFill;
    [self.liveView addSubview:self.localView];
    self.localIsRemote = NO;
}
- (void)setLocalIsRemote:(RCCRRemoteViewCellCollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath{
    self.localView.fillMode = RCRTCVideoFillModeAspectFill;
    [cell addLocalView:self.localView];
    cell.remoteView.frame = self.remoteVideoView.frame;
    cell.remoteView.clipsToBounds = YES;
    [self.liveView addSubview:cell.remoteView];
    [self setSelectCell:cell indexPath:indexPath];
    self.localIsRemote = YES;
}
- (void)setSelectCell:(RCCRRemoteViewCellCollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath{
    self.selectModel = cell.remoteModel;
    self.selectIndexPath = indexPath;
    self.selectCell = cell;
}

#pragma mark - RCCRHostInformationViewDelegate
- (void)clickAttentionBtn:(UIButton *)sender {
    if ([[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] isLogin]) {
        //  避免重复点击
        if (sender.selected) {
            return;
        }
        self.hostInformationView.attentionBtn.selected = YES;
        //  发送关注消息
        RCChatroomFollow *followMessage = [[RCChatroomFollow alloc] init];
        __weak __typeof(&*self)weakSelf = self;
        [self sendMessage:followMessage pushContent:nil success:^(long messageId) {
            
            RCCRLiveModel *hostModel = weakSelf.hostInformationView.hostModel;
            hostModel.fansAmount++;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.hostInformationView setDataModel:hostModel];
            });
            
        } error:^(RCErrorCode nErrorCode, long messageId) {
        }];
        
    } else {
        CGRect frame = self.hostInformationView.frame;
        frame.origin.y = self.view.bounds.size.height;
        
        __weak __typeof(&*self)weakSelf = self;
        [UIView animateWithDuration:0.2 animations:^{
            [weakSelf.hostInformationView setFrame:frame];
        } completion:^(BOOL finished) {
            [weakSelf.hostInformationView setHidden:YES];
            
        }];
    }
}

#pragma mark - RCCRgiftViewDelegate
//  发送礼物消息
- (void)sendGift:(RCCRGiftModel *)giftModel {
    RCChatroomGift *giftMessage = [[RCChatroomGift alloc] init];
    giftMessage.number = (int)giftModel.giftNumber;
    giftMessage.id = giftModel.giftId;
    [self sendMessage:giftMessage pushContent:nil success:nil error:nil];
    
    [self presentGiftAnimation:giftModel userInfo:[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].currentUserInfo];
    RCCRLiveModel *liveModel = self.hostInformationView.hostModel;
    liveModel.giftAmount += giftModel.giftNumber;
    [self.hostInformationView setDataModel:liveModel];
}


- (void)presentGiftAnimation:(RCCRGiftModel *)giftModel userInfo:(RCUserInfo *)userInfo{
    //动画效果需要在主线程中进行（固定的动画形式）
    //    CGFloat duringTime = 0.5 + 0.5 + 0.2*giftModel.giftNumber;
    __weak __typeof(&*self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
        if (self.forbidGiftAinimation) {
            return;
        }
        weakSelf.showGiftView = [[UIView alloc] initWithFrame:CGRectMake(-150, 100, 160, 50)];
        weakSelf.showGiftView.layer.cornerRadius = 25;
        UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
        [headerImageView setBackgroundColor:[UIColor redColor]];
        [headerImageView.layer setCornerRadius:24];
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 2, 56, 20)];
        [nameLabel setNumberOfLines:0];
        [nameLabel setText:userInfo.name];
        [nameLabel setFont:[UIFont systemFontOfSize:12]];
        [nameLabel setTextColor:[UIColor whiteColor]];
        [nameLabel setTextAlignment:NSTextAlignmentCenter];
        [weakSelf.showGiftView addSubview:nameLabel];
        UILabel *gifName = [[UILabel alloc] initWithFrame:CGRectMake(50, 25, 56, 20)];
        NSString *name = [self getGifName:giftModel.giftId];
        [gifName setText:name];
        [gifName setTextColor:[UIColor yellowColor]];
        [gifName setFont:[UIFont systemFontOfSize:12]];
        [weakSelf.showGiftView addSubview:gifName];
        [headerImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"audience%@",userInfo.portraitUri]]];
        [weakSelf.showGiftView addSubview:headerImageView];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 0, 50, 50)];
        [weakSelf.showGiftView setBackgroundColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.4]];
        [weakSelf.showGiftView  addSubview:imageView];
        imageView.image = [UIImage imageNamed:giftModel.giftImageName];
        weakSelf.giftNumberLbl = [[RCCRGiftNumberLabel alloc] initWithFrame:CGRectMake(160, 0, 100, 50)];
        weakSelf.giftNumberLbl.outLineWidth = 5;
        weakSelf.giftNumberLbl.outLinetextColor = [UIColor grayColor];
        weakSelf.giftNumberLbl.labelTextColor = [UIColor orangeColor];
        weakSelf.giftNumberLbl.text = @"";
        weakSelf.giftNumberLbl.textAlignment = NSTextAlignmentLeft;
        weakSelf.giftNumberLbl.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:36];
        [weakSelf.showGiftView  addSubview:weakSelf.giftNumberLbl];
        
        [weakSelf.view addSubview:self.showGiftView];
        self.forbidGiftAinimation = YES;
        
        //  逻辑：平移0.5秒；禁止0.2秒；变换数字，每次变换0.2秒，变换完数字，再禁止0.2秒，再移除；
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.showGiftView.center = CGPointMake(120, 200);
        } completion:^(BOOL finished) {
            //  数字动画
            for (int i = 0; i<giftModel.giftNumber+2; i++) {
                dispatch_after(dispatch_time(0, (int64_t)(i*0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (!((i == 0) || (i == giftModel.giftNumber+1))) {
                        [weakSelf.giftNumberLbl setText:[NSString stringWithFormat:@"x%d",i]];
                    }
                    if (i == giftModel.giftNumber + 1) {
                        [UIView animateWithDuration:0.5 animations:^{
                            weakSelf.showGiftView.center = CGPointMake(-100,200);
                        } completion:^(BOOL finished) {
                            weakSelf.forbidGiftAinimation = NO;
                            [weakSelf.showGiftView removeFromSuperview];
                        }];
                    }
                });
            }
        }];
    });
}
- (NSString *)getGifName:(NSString *)gifId{
    if ([gifId isEqualToString:@"GiftId_1"]) {
        return @"送出蛋糕";
    }
    if ([gifId isEqualToString:@"GiftId_2"]) {
        return @"送出气球";
    }
    if ([gifId isEqualToString:@"GiftId_3"]) {
        return @"送出花儿";
    }
    if ([gifId isEqualToString:@"GiftId_4"]) {
        return @"送出项链";
    }
    if ([gifId isEqualToString:@"GiftId_5"]) {
        return @"送出戒指";
    }
    return @"";
}
#pragma mark - ban and block notice

- (void)presentAlert:(NSString *)content {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:content message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self quitConversationViewAndClear];
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)insertNotificationMessage:(NSString *)content {
    RCChatroomNotification *notify = [RCChatroomNotification new];
    notify.content = content;
    RCMessage *message = [[RCMessage alloc] initWithType:self.conversationType
                                                targetId:self.targetId
                                               direction:MessageDirection_SEND
                                               messageId:-1
                                                 content:notify];
    message.senderUserId = [RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].currentUserInfo.userId;
    [self appendAndDisplayMessage:message];
}

#pragma mark - views init
/**
 *  注册cell
 *
 *  @param cellClass  cell类型
 *  @param identifier cell标示
 */
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    [self.conversationMessageCollectionView registerClass:cellClass
                               forCellWithReuseIdentifier:identifier];
}

- (void)initializedSubViews {
    
    UITapGestureRecognizer *resetBottomTapGesture =[[UITapGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(resetBottomGesture:)];
    resetBottomTapGesture.delegate = self;
    [self.view addGestureRecognizer:resetBottomTapGesture];
    
    CGSize size = self.view.bounds.size;
    //    CGRect bounds = self.view.bounds;
    
    
    CGFloat topExtraDistance = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat bottomExtraDistance  = 0;
    if (@available(iOS 11.0, *)) {
        bottomExtraDistance = [self getIPhonexExtraBottomHeight];
    }
    
    //  这里默认使用了一张背景图，你可以将live设置为你的播放器
    [self.view addSubview:self.liveView];
    //    _liveView.backgroundColor = [UIColor colorWithHexString:@"0x00003E" alpha:1.0];
    [_liveView setFrame:self.view.bounds];
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    gradientLayer.frame = CGRectMake(0, 0, _liveView.frame.size.width, _liveView.frame.size.height );
    gradientLayer.colors = @[(__bridge id)[UIColor colorWithHexString:@"0x333333" alpha:1].CGColor, (__bridge id)[UIColor colorWithHexString:@"0x131313" alpha:1].CGColor];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    [_liveView.layer addSublayer:gradientLayer];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat f = (16.0/9.0 );
    CGFloat height = width * f;
    RCRTCLocalVideoView * localView = [[RCRTCLocalVideoView alloc]initWithFrame:CGRectMake(0, ([UIScreen mainScreen].bounds.size.height - height) / 2, width, height)];
    self.localViewFrame = localView.frame;
    if (self.localView) {
        [self.localView removeFromSuperview];
    }
    
    self.localView = localView;
    [self.localView setFillMode:(RCRTCVideoFillModeAspectFill)];
    self.localView.hidden = YES;
    
    //remoteView
    
    RCRTCRemoteVideoView *remoreView = [[RCRTCRemoteVideoView alloc] initWithFrame:CGRectMake(0, ([UIScreen mainScreen].bounds.size.height - height) / 2, width, height)];
    self.remoteVideoView = remoreView;
//    [self.remoteVideoView setBackgroundColor:[UIColor redColor]];
    self.remoteVideoView.hidden = YES;
    [self.remoteVideoView setFillMode:RCRTCVideoFillModeAspect];
    [self.liveView addSubview:self.localView];
    [self.liveView setContentMode:UIViewContentModeScaleAspectFit];
    [self.liveView addSubview:self.remoteVideoView];
    
    //  顶部
    [self.view addSubview:self.topContentView];
    [_topContentView setFrame:CGRectMake(0, topExtraDistance, size.width, 35)];
    
    [_topContentView addSubview:self.hostView];
    [_hostView setFrame:CGRectMake(10, 0, 85, 35)];
    [_hostView.layer setCornerRadius:35/2];
    [_hostView setBackgroundColor:[UIColor blackColor]];
    [_hostView setAlpha:0.5];
    
    [_hostView addSubview:self.hostPortraitImgV];
    [_hostPortraitImgV setFrame:CGRectMake(1, 1, 33, 33)];
    [_hostPortraitImgV.layer setCornerRadius:33/2];
    [_hostPortraitImgV.layer setMasksToBounds:YES];
    
    UITapGestureRecognizer *hostPotraitClickGesture =[[UITapGestureRecognizer alloc]
                                                      initWithTarget:self
                                                      action:@selector(hostPotraitClick:)];
    [_hostView addGestureRecognizer:hostPotraitClickGesture];
    
    [_hostView addSubview:self.hostNameLbl];
    [_hostNameLbl setFrame:CGRectMake(37, 1, 45, 14)];
    
    [_hostView addSubview:self.audienceNumberLbl];
    [_audienceNumberLbl setFrame:CGRectMake(37, 35 - 1 - 14, 45, 14)];
    [_topContentView addSubview:self.portraitCollectionView];
    if (![self.model.pubUserId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        self.portraitCollectionView.hidden = YES;
    }
    [_portraitCollectionView setFrame:CGRectMake(100, 0, size.width - 100 - 30, 35)];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 16;
    layout.sectionInset = UIEdgeInsetsMake(0.0f, 20.0f, 0.0f, 20.0f);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [_portraitCollectionView setCollectionViewLayout:layout animated:NO completion:nil];
    //    UITapGestureRecognizer *audiencePotraitClickGesture =[[UITapGestureRecognizer alloc]
    //                                                      initWithTarget:self
    //                                                      action:@selector(audiencePotraitClick:)];
    //    [_portraitCollectionView addGestureRecognizer:audiencePotraitClickGesture];
    
    [_topContentView addSubview:self.backBtn];
    [_backBtn setFrame:CGRectMake(size.width - 40, 5,30, 30)];
    
    //  消息展示界面和输入框
    [self.view addSubview:self.messageContentView];
    [_messageContentView setFrame:CGRectMake(0, size.height - 237 - bottomExtraDistance, size.width, 237)];
    
    [_messageContentView addSubview:self.conversationMessageCollectionView];
    CGFloat distance = [self getIPhonexExtraBottomHeight] > 0 ? 70 : 50;
    [_conversationMessageCollectionView setFrame:CGRectMake(0, 0, 300, 237 - distance)];
    UICollectionViewFlowLayout *customFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    customFlowLayout.minimumLineSpacing = 2;
    customFlowLayout.sectionInset = UIEdgeInsetsMake(10.0f, 0.0f,5.0f, 0.0f);
    customFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    [_conversationMessageCollectionView setCollectionViewLayout:customFlowLayout animated:NO completion:nil];
    
    [_messageContentView addSubview:self.inputBar];
    [_inputBar setBackgroundColor: [UIColor whiteColor]];
    [_inputBar setFrame:CGRectMake(0, 237 - 50, size.width , 50)];
    [_inputBar setHidden:YES];
    
    //  底部按钮
    [self.view addSubview:self.bottomBtnContentView];
    [_bottomBtnContentView setFrame:CGRectMake(0, size.height - 50 - bottomExtraDistance, size.width, 50)];
    [_bottomBtnContentView setBackgroundColor:[UIColor clearColor]];
    //    [_bottomBtnContentView setAlpha: 0.3];
    
    [_bottomBtnContentView addSubview:self.commentBtn];
    [_commentBtn setFrame:CGRectMake(10, 10, 35, 35)];
    if (self.model.liveMode != RCCRLiveModeHost) {
        [_bottomBtnContentView addSubview:self.danmakuBtn];
    }
    [_danmakuBtn setFrame:CGRectMake(size.width - 35*3 - 10*4, 10, 35, 35)];
    [_danmakuBtn setBackgroundColor:[UIColor blackColor]];
    [_danmakuBtn.layer setCornerRadius:35/2];
    [_danmakuBtn.layer setMasksToBounds:YES];
    
    if (self.model.liveMode != RCCRLiveModeHost) {
        [_bottomBtnContentView addSubview:self.giftBtn];
    }
    
    [_giftBtn setFrame:CGRectMake(size.width - 35*2 - 10*3, 10, 35, 35)];
    
    if (self.model.liveMode != RCCRLiveModeHost) {
        [_bottomBtnContentView addSubview:self.praiseBtn];
    }
    [_praiseBtn setFrame:CGRectMake(size.width - 35 - 10*2, 10, 35, 35)];
    if (self.model.liveMode == RCCRLiveModeHost) {
        [_bottomBtnContentView addSubview:self.settingBtn];
        [_settingBtn setFrame:CGRectMake(size.width - 35 - 10*2, 10, 35, 35)];
    }
    
    
    //  底部隐藏控件
    [self.view addSubview:self.hostInformationView];
    [_hostInformationView setFrame:CGRectMake(10, size.height, size.width - 20, [self getIPhonexExtraBottomHeight] > 0 ? 234 : 200)];
    [_hostInformationView setBackgroundColor:[UIColor blackColor]];
    [_hostInformationView setHidden:YES];
    
    [self.view addSubview:self.audienceListView];
    [_audienceListView setFrame:CGRectMake(10, size.height, size.width - 20, [self getIPhonexExtraBottomHeight] > 0 ? 334 : 300)];
    [_audienceListView setBackgroundColor:[UIColor blackColor]];
    [_audienceListView setHidden:NO];
    self.oriFrame = self.audienceListView.frame;
    
    
    [self.view addSubview:self.giftListView];
    [_giftListView setFrame:CGRectMake(10, size.height, size.width - 20, [self getIPhonexExtraBottomHeight] > 0 ? 274 : 240)];
    //    [_giftListView setBackgroundColor:[UIColor blackColor]];
    [_giftListView setHidden:YES];
    
    [self registerClass:[RCCRTextMessageCell class]forCellWithReuseIdentifier:textCellIndentifier];
    [self registerClass:[RCCRTextMessageCell class]forCellWithReuseIdentifier:startAndEndCellIndentifier];
    //
    //    NSMutableArray *dataSource= [NSMutableArray array];
    //    for (int i = 0 ; i < 10; i ++ ) {
    //        RCCRRemoteModel *model = [[RCCRRemoteModel alloc] init];
    //        [dataSource addObject:model];
    //    }
    RCCRRemoteView *remoteView = [[RCCRRemoteView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 100)];
    self.remoteView = remoteView;
    self.remoteView.delegate = self;
    
    [self.view addSubview:remoteView];
    if (self.model.liveMode == RCCRLiveModeAudience) {
        [self addButtonBar];
    }
    
    //    [remoteView setDataSources:dataSource];
    
}
- (void)addButtonBar{
    RCCRButtonBar *bar = [[RCCRButtonBar alloc] init];
    self.buttonBar = bar;
    bar.delegate = self;
    [self.view addSubview:bar];
    [bar reloadData:(self.model.liveMode == RCCRLiveModeHost ? RCCRButtonBarTypeHost : RCCRButtonBarTypeNormal)];
    
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self reloadButtonBar];
}
- (void)reloadButtonBar{
    CGSize size = [self.buttonBar getSise];
    CGFloat top = (self.view.frame.size.height - size.height) / 2;
    [self.buttonBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).offset(-15);
        make.top.mas_equalTo(self.view.mas_top).offset(top);
        make.width.mas_equalTo(@(size.width));
        make.height.mas_equalTo(@(size.height));
    }];
}
- (UIView *)liveView {
    if (!_liveView) {
        _liveView = [[UIView alloc] init];
        [_liveView setBackgroundColor:[UIColor orangeColor]];
    }
    return _liveView;
}

- (UIView *)topContentView {
    if (!_topContentView) {
        _topContentView = [[UIView alloc] init];
        [_topContentView setBackgroundColor:[UIColor clearColor]];
    }
    return _topContentView;
}

- (UIView *)hostView {
    if (!_hostView) {
        _hostView = [[UIView alloc] init];
    }
    return _hostView;
}

- (UIImageView *)hostPortraitImgV {
    if (!_hostPortraitImgV) {
        _hostPortraitImgV = [[UIImageView alloc] init];
        [_hostPortraitImgV setUserInteractionEnabled:YES];
    }
    return _hostPortraitImgV;
}

- (RCCRHostInformationView *)hostInformationView {
    if (!_hostInformationView) {
        _hostInformationView = [[RCCRHostInformationView alloc] init];
        [_hostInformationView setDelegate:self];
    }
    return _hostInformationView;
}

- (UILabel *)hostNameLbl {
    if (!_hostNameLbl) {
        _hostNameLbl = [[UILabel alloc] init];
        [_hostNameLbl setTextAlignment:NSTextAlignmentLeft];
        [_hostNameLbl setFont:[UIFont systemFontOfSize:12.0f]];
        [_hostNameLbl setNumberOfLines:1];
        [_hostNameLbl setTextColor:[UIColor whiteColor]];
    }
    return  _hostNameLbl;
}

- (UILabel *)audienceNumberLbl {
    if (!_audienceNumberLbl) {
        _audienceNumberLbl = [[UILabel alloc] init];
        [_audienceNumberLbl setTextAlignment:NSTextAlignmentLeft];
        [_audienceNumberLbl setFont:[UIFont systemFontOfSize:12.0f]];
        [_audienceNumberLbl setNumberOfLines:1];
        [_audienceNumberLbl setTextColor:[UIColor orangeColor]];
    }
    return  _audienceNumberLbl;
}

- (UICollectionView *)portraitCollectionView {
    if (!_portraitCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _portraitCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_portraitCollectionView setDelegate:self];
        [_portraitCollectionView setDataSource:self];
        [_portraitCollectionView setBackgroundColor: [UIColor clearColor]];
        [_portraitCollectionView registerClass:[RCCRPortraitCollectionViewCell class] forCellWithReuseIdentifier:portraitCollectionViewCellIndentifier];
        [_portraitCollectionView setBackgroundColor:[UIColor clearColor]];
    }
    return _portraitCollectionView;
}

- (RCCRAudienceListView *)audienceListView {
    if (!_audienceListView) {
        _audienceListView = [[RCCRAudienceListView alloc] init];
        _audienceListView.delegate = self;
    }
    return _audienceListView;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] init];
        [_backBtn addTarget:self
                     action:@selector(backButtonItemPressed:)
           forControlEvents:UIControlEventTouchUpInside];
        [_backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    }
    return _backBtn;
}

- (UIView *)messageContentView {
    if (!_messageContentView) {
        _messageContentView = [[UIView alloc] init];
        [_messageContentView setBackgroundColor: [UIColor clearColor]];
    }
    return _messageContentView;
}

- (UICollectionView *)conversationMessageCollectionView {
    if (!_conversationMessageCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _conversationMessageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_conversationMessageCollectionView setDelegate:self];
        [_conversationMessageCollectionView setDataSource:self];
        [_conversationMessageCollectionView setBackgroundColor: [UIColor clearColor]];
        [_conversationMessageCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:ConversationMessageCollectionViewCell];
    }
    return _conversationMessageCollectionView;
}

- (RCCRInputBarControl *)inputBar {
    if (!_inputBar) {
        _inputBar = [[RCCRInputBarControl alloc] initWithStatus:RCCRBottomBarStatusDefault];
        [_inputBar setDelegate:self];
    }
    return _inputBar;
}

- (UIView *)bottomBtnContentView {
    if (!_bottomBtnContentView) {
        _bottomBtnContentView = [[UIView alloc] init];
        [_bottomBtnContentView setBackgroundColor:[UIColor clearColor]];
    }
    return _bottomBtnContentView;
}

- (UIButton *)commentBtn {
    if (!_commentBtn) {
        _commentBtn = [[UIButton alloc] init];
        [_commentBtn addTarget:self
                        action:@selector(commentBtnPressed:)
              forControlEvents:UIControlEventTouchUpInside];
        [_commentBtn setImage:[UIImage imageNamed:@"feedback"] forState:UIControlStateNormal];
    }
    return _commentBtn;
}

- (UIButton *)danmakuBtn {
    if (!_danmakuBtn) {
        _danmakuBtn = [[UIButton alloc] init];
        [_danmakuBtn addTarget:self
                        action:@selector(danmakuBtnPressed:)
              forControlEvents:UIControlEventTouchUpInside];
        [_danmakuBtn setTitle:@"弹" forState:UIControlStateNormal];
    }
    return _danmakuBtn;
}


- (UIButton *)giftBtn {
    if (!_giftBtn) {
        _giftBtn = [[UIButton alloc] init];
        [_giftBtn addTarget:self
                     action:@selector(giftBtnPressed:)
           forControlEvents:UIControlEventTouchUpInside];
        [_giftBtn setImage:[UIImage imageNamed:@"gift0"] forState:UIControlStateNormal];
    }
    return _giftBtn;
}

- (RCCRGiftListView *)giftListView {
    if (!_giftListView) {
        _giftListView = [[RCCRGiftListView alloc] init];
        [_giftListView setDelegate:self];
    }
    return _giftListView;
}

- (UIButton *)praiseBtn {
    if (!_praiseBtn) {
        _praiseBtn = [[UIButton alloc] init];
        [_praiseBtn addTarget:self
                       action:@selector(praiseBtnPressed:)
             forControlEvents:UIControlEventTouchUpInside];
        [_praiseBtn setImage:[UIImage imageNamed:@"heartIcon"] forState:UIControlStateNormal];
    }
    return _praiseBtn;
}
-(UIButton *)settingBtn{
    if (!_settingBtn) {
        _settingBtn = [[UIButton alloc] init];
        [_settingBtn addTarget:self action:@selector(settingBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_settingBtn setImage:[UIImage imageNamed:@"设置"] forState:UIControlStateNormal];
    }
    return _settingBtn;
}
-(RCCRSettingModel *)settingModel{
    if (!_settingModel) {
        _settingModel = [[RCCRSettingModel alloc] init];
        _settingModel.layoutModel = [[RCCRLiveLayoutModel alloc] initWithType:RCCRLiveLayoutTypeSuspension];
        _settingModel.layoutModel.suspensionCrop = NO;
    }
    return _settingModel;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
-(void)inputTextViewTextViewDidChange:(UITextView *)textView{
    if (self.isSendDanmaku) {
        if (textView.text.length > 50) {
            textView.text = [textView.text substringToIndex:50];
        }
    }
}
- (void)didTouchMic:(BOOL)open{
    [[RCRTCEngine sharedInstance].defaultAudioStream setMicrophoneDisable:open];
    if (open) {
        [self showToast:@"已静音"];
    } else {
        [self showToast:@"已解除静音"];
    }
    
}
- (void)didTouchSpeaker:(BOOL)open{
    [[RCRTCEngine sharedInstance] useSpeaker:!open];
    if (!open) {
        [self showToast:@"已开启扬声器模式"];
    } else {
        [self showToast:@"已开启听筒模式"];
    }
}
- (void)didTouchCam:(BOOL)open{
    [[RCRTCEngine sharedInstance].defaultVideoStream switchCamera];
}
- (void)showToast:(NSString *)toast{
    dispatch_async(dispatch_get_main_queue(), ^{
        [RCActiveWheel showPromptHUDAddedTo:self.view text:toast];
    });
}
- (void)didTouchFile:(UIButton *)btn{
    if (btn.selected) {
        [self startPublishVideoFile];
    } else {
        [self stopPublishVideoFile];
    }
}
- (void)didTouchCDN{
    RCCRCDNViewController *cdn = [[RCCRCDNViewController alloc] init];
    cdn.delegate = self;
    cdn.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self.navigationController presentViewController:cdn animated:YES completion:nil];
}
-(void)didAddCDN:(NSString *)cdn{

    [self.liveModuleManager addCdn:cdn completion:^(BOOL isSuccess, RCRTCCode code, NSArray * _Nonnull arr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isSuccess) {
                [RCActiveWheel showPromptHUDAddedTo:self.view text:@"设置成功"];
            } else {
                [RCActiveWheel showPromptHUDAddedTo:self.view text:@"设置失败"];

            }
        });
    }];
}
-(void)didRemoveCDN:(NSString *)cdn{
    [self.liveModuleManager removeCdn:cdn completion:^(BOOL isSuccess, RCRTCCode code, NSArray * _Nonnull arr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isSuccess) {
                [RCActiveWheel showPromptHUDAddedTo:self.view text:@"移除成功"];
            } else {
                [RCActiveWheel showPromptHUDAddedTo:self.view text:@"移除失败"];

            }
        });
    }];
}
#pragma mark - demmon bar delegate
-(void)didTouchButton:(UIButton *)btn index:(RCCRButtonType)index{
    switch (index) {
        case RCCRButtonTypeMic:
        {
            [self didTouchMic:btn.selected];
        }
            break;
        case RCCRButtonTypeSpeaker:{
            [self didTouchSpeaker:btn.selected];
        }
            break;
        case RCCRButtonTypeCamera:{
            [self didTouchCam:btn.selected];
        }
            break;
        case RCCRButtonTypeFile:
        {
            [self didTouchFile:btn];
        }
            break;
        case RCCRButtonTypeCDN:
        {
            [self didTouchCDN];
        }
            break;
            
        default:
            break;
    }
}
@end
