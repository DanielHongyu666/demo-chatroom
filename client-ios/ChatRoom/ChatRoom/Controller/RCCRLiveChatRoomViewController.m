//
//  RCCRLiveChatRoomViewController.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/9.
//  Copyright © 2018年 罗骏. All rights reserved.
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
static NSString * const banNotifyContent = @"您已被管理员禁言";

#define kRandomColor [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:1]

static NSString * const portraitCollectionViewCellIndentifier = @"portraitCollectionViewCellIndentifier";

static NSString * const ConversationMessageCollectionViewCell = @"ConversationMessageCollectionViewCell";

/**
 *  文本cell标示
 */
static NSString *const textCellIndentifier = @"textCellIndentifier";

static NSString *const startAndEndCellIndentifier = @"startAndEndCellIndentifier";

@interface RCCRLiveChatRoomViewController () <UICollectionViewDelegate, UICollectionViewDataSource, RCCRInputBarControlDelegate, UIGestureRecognizerDelegate, RCCRLoginViewDelegate, RCCRGiftViewDelegate, RCCRHostInformationViewDelegate>

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
 登录的界面
 */
@property(nonatomic,strong)RCCRLoginView *loginView;

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
    self.conversationMessageCollectionView = nil;
    self.targetId = nil;
    [self registerNotification];
    self.defaultHistoryMessageCountOfChatRoom = 10;
    self.lastClickPraiseTime = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
    //聊天室类型进入时需要调用加入聊天室接口，退出时需要调用退出聊天室接口
    if (ConversationType_CHATROOM == self.conversationType) {
//        __weak __typeof(&*self)weakSelf = self;
        [[RCIMClient sharedRCIMClient]
         joinChatRoom:self.targetId
         messageCount:-1
         success:^{
             dispatch_async(dispatch_get_main_queue(), ^{
                 
//                 [weakSelf.livePlayingManager startPlaying];
             });
             NSLog(@"加入聊天室成功");
         }
         error:^(RCErrorCode status) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (status == KICKED_FROM_CHATROOM) {
                     // 提示错误信息
                 } else {
                     
                 }
             });
         }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];

    [self.hostPortraitImgV setImage:[UIImage imageNamed:self.model.hostPortrait]];
    [self.hostNameLbl setText:self.model.hostName];
    [self.audienceNumberLbl setText:[NSString stringWithFormat:@"%ld人",(long)self.model.audienceAmount]];
    
    //  获取数据,刷新界面
    for (int i = 0; i<10; i++) {
        RCCRAudienceModel *audienceModel = [[RCCRAudienceModel alloc] init];
        audienceModel.audienceName = [NSString stringWithFormat:@"观众%d号",i+1];
        audienceModel.audiencePortrait = [NSString stringWithFormat:@"audience%d",i+1];
        [self.audienceList addObject:audienceModel];
    }
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
    if (self.conversationType == ConversationType_CHATROOM) {
        //退出聊天室
        RCChatroomUserQuit *quitMessage = [[RCChatroomUserQuit alloc] init];
        quitMessage.id = [RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].currentUserInfo.userId;
        [self sendMessage:quitMessage pushContent:nil success:nil error:nil];
        [[RCIMClient sharedRCIMClient] quitChatRoom:self.targetId
                                            success:^{
                                                
                                                //断开融云连接，如果你退出聊天室后还有融云的其他通讯功能操作，可以不用断开融云连接，否则断开连接后需要重新connectWithToken才能使用融云的功能
//                                                [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] logoutRongCloud];
                                            } error:^(RCErrorCode status) {
                                                
                                            }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
            [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] setIsLogin:NO];
        });
    }
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
        [messageContent isMemberOfClass:[RCChatroomEnd class]]){
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
            [self showDanmaku:text userId:[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].currentUserInfo.userId];
            [self sendMessage:barrageMessage pushContent:nil success:nil error:nil];
        }
        
    } else {
        RCTextMessage *rcTextMessage = [RCTextMessage messageWithContent:text];
        [self sendMessage:rcTextMessage pushContent:nil success:nil error:nil];
    }
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
    
    if (model.conversationType == self.conversationType &&
        [model.targetId isEqual:self.targetId]) {
        __weak typeof(&*self) __blockSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            //  对礼物消息,赞消息进行拦截，展示动画，不插入到数据源中,对封禁消息，弹出alert
            if (rcMessage) {
                if ([rcMessage.content isMemberOfClass:[RCChatroomGift class]])  {
                    RCChatroomGift *giftMessage = (RCChatroomGift *)rcMessage.content;
                    RCCRGiftModel *model = [[RCCRGiftModel alloc] initWithMessage:giftMessage];
                    [__blockSelf presentGiftAnimation:model];
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
                } else if ([rcMessage.content isMemberOfClass:[RCChatroomUserQuit class]]) {
                    //  退出聊天室消息直接过滤
                    return;
                } else if ([rcMessage.content isMemberOfClass:[RCChatroomUserBlock class]]) {
                    RCChatroomUserBlock *blockMessage = (RCChatroomUserBlock*)rcMessage.content;
                    if ([blockMessage.id isEqualToString:[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].currentUserInfo.userId]) {
                        [__blockSelf presentAlert:@"您被管理员踢出聊天室"];
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
    }
}

/**
 *  将消息加入本地数组
 */
- (void)appendAndDisplayMessage:(RCMessage *)rcMessage {
    if (!rcMessage) {
        return;
    }
    RCCRMessageModel *model = [[RCCRMessageModel alloc] initWithMessage:rcMessage];
    model.userInfo = [[RCCRManager sharedRCCRManager]getUserInfo:rcMessage.senderUserId];
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
        [self showDanmaku:danmakuMessage.content userId:message.senderUserId];
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
- (void)showDanmaku:(NSString *)text userId:(NSString *)userId {
    if(!text || text.length == 0){
        return;
    }
    RCDDanmaku *danmaku = [[RCDDanmaku alloc]init];
    danmaku.contentStr = [[NSAttributedString alloc]initWithString:text attributes:@{NSForegroundColorAttributeName : kRandomColor}];
//    RCCRAudienceModel *audienceModel = [[RCCRAudienceModel alloc] init];
    RCUserInfo *currentUserInfo = [[RCUserInfo alloc] init];
    currentUserInfo = [[RCCRManager sharedRCCRManager] getUserInfo:userId];
//    audienceModel.audienceName = currentUserInfo.name;
//    audienceModel.audiencePortrait = currentUserInfo.portraitUri;
    danmaku.model = currentUserInfo;
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
    if (!self.loginView.hidden) {
        CGRect frame = self.loginView.frame;
        frame.origin.y = height;
        [UIView animateWithDuration:0.2 animations:^{
            [weakSelf.loginView setFrame:frame];
        } completion:^(BOOL finished) {
            [weakSelf.loginView setHidden:YES];
        }];
    }
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
    if (!self.audienceListView.hidden) {
        return;
    }
    CGRect frame = self.audienceListView.frame;
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
        CGRect frame = self.loginView.frame;
        frame.origin.y -= frame.size.height;
        [self.loginView setHidden:NO];
        __weak __typeof(&*self)weakSelf = self;
        [UIView animateWithDuration:0.2 animations:^{
            [weakSelf.loginView setFrame:frame];
        } completion:nil];
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
        CGRect frame = self.loginView.frame;
        frame.origin.y -= frame.size.height;
        [self.loginView setHidden:NO];
        __weak __typeof(&*self)weakSelf = self;
        [UIView animateWithDuration:0.2 animations:^{
            [weakSelf.loginView setFrame:frame];
        } completion:nil];
    }
}

/**
 送礼物按钮事件
 */
- (void)giftBtnPressed:(id)sender {
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
            //  弹出登录框
            CGRect frame = weakSelf.loginView.frame;
            frame.origin.y -= frame.size.height;
            [weakSelf.loginView setHidden:NO];
            [UIView animateWithDuration:0.2 animations:^{
                [weakSelf.loginView setFrame:frame];
            } completion:nil];
        }];
    }
}

/**
 点赞
 */
- (void)praiseBtnPressed:(id)sender {
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
            //  弹出登录框
            CGRect frame = weakSelf.loginView.frame;
            frame.origin.y -= frame.size.height;
            [weakSelf.loginView setHidden:NO];
            [UIView animateWithDuration:0.2 animations:^{
                [weakSelf.loginView setFrame:frame];
            } completion:nil];
        }];
    }
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
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"] || [NSStringFromClass([touch.view class]) isEqualToString:@"RCCRgiftListView"]) {
        return NO;
    }
    //在view中点击的坐标
    CGPoint touchPoint = [touch locationInView:self.view];
    //判断点击的坐标是否在限制的控件的范围内
    CGRect portraitCollectionViewRect = [self.view convertRect:self.portraitCollectionView.frame fromView:self.topContentView];
    bool value = CGRectContainsPoint(self.hostInformationView.frame, touchPoint) || CGRectContainsPoint(portraitCollectionViewRect, touchPoint) || CGRectContainsPoint(self.loginView.frame, touchPoint) || CGRectContainsPoint(self.giftListView.frame, touchPoint);
    
    if (value) {
        return NO;
    }
    return YES;
}

#pragma mark - RCCRLoginViewDelegate
- (void)clickLoginBtn:(UIButton *)loginBtn {
    // 登录成功
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] setIsLogin:YES];
    RCChatroomWelcome *joinChatroomMessage = [[RCChatroomWelcome alloc]init];
    [joinChatroomMessage setId:[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].currentUserInfo.userId];
    [self sendMessage:joinChatroomMessage pushContent:nil success:nil error:nil];
    [self setDefaultBottomViewStatus];
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
            //  弹出登录框
            CGRect frame = weakSelf.loginView.frame;
            frame.origin.y -= frame.size.height;
            [weakSelf.loginView setHidden:NO];
            [UIView animateWithDuration:0.2 animations:^{
                [weakSelf.loginView setFrame:frame];
            } completion:nil];
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
    
    [self presentGiftAnimation:giftModel];
    RCCRLiveModel *liveModel = self.hostInformationView.hostModel;
    liveModel.giftAmount += giftModel.giftNumber;
    [self.hostInformationView setDataModel:liveModel];
}


- (void)presentGiftAnimation:(RCCRGiftModel *)giftModel {
    //动画效果需要在主线程中进行（固定的动画形式）
//    CGFloat duringTime = 0.5 + 0.5 + 0.2*giftModel.giftNumber;
    __weak __typeof(&*self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
        if (self.forbidGiftAinimation) {
            return;
        }
        weakSelf.showGiftView = [[UIView alloc] initWithFrame:CGRectMake(-150, 100, 160, 50)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [weakSelf.showGiftView  addSubview:imageView];
        imageView.image = [UIImage imageNamed:giftModel.giftImageName];
        weakSelf.giftNumberLbl = [[RCCRGiftNumberLabel alloc] initWithFrame:CGRectMake(60, 0, 100, 50)];
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
    CGFloat topExtraDistance = ISX ? 44 : 20;
    CGFloat bottomExtraDistance = ISX ? 34 : 0;

    //  这里默认使用了一张背景图，你可以将live设置为你的播放器
    [self.view addSubview:self.liveView];
    [_liveView setFrame:self.view.bounds];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backGround"]];
    [imgView setFrame:self.view.bounds];
    [_liveView addSubview:imgView];
    
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
    [_backBtn setFrame:CGRectMake(size.width - 30, 5, 25, 25)];
    
    //  消息展示界面和输入框
    [self.view addSubview:self.messageContentView];
    [_messageContentView setFrame:CGRectMake(0, size.height - 237 - bottomExtraDistance, size.width, 237)];
    
    [_messageContentView addSubview:self.conversationMessageCollectionView];
    [_conversationMessageCollectionView setFrame:CGRectMake(0, 0, 300, 237 - 50)];
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
    
    [_bottomBtnContentView addSubview:self.danmakuBtn];
    [_danmakuBtn setFrame:CGRectMake(size.width - 35*3 - 10*4, 10, 35, 35)];
    [_danmakuBtn setBackgroundColor:[UIColor blackColor]];
    [_danmakuBtn.layer setCornerRadius:35/2];
    [_danmakuBtn.layer setMasksToBounds:YES];
    
    [_bottomBtnContentView addSubview:self.giftBtn];
    [_giftBtn setFrame:CGRectMake(size.width - 35*2 - 10*3, 10, 35, 35)];
    
    [_bottomBtnContentView addSubview:self.praiseBtn];
    [_praiseBtn setFrame:CGRectMake(size.width - 35 - 10*2, 10, 35, 35)];
    
    //  底部隐藏控件
    [self.view addSubview:self.hostInformationView];
    [_hostInformationView setFrame:CGRectMake(10, size.height, size.width - 20, ISX ? 234 : 200)];
    [_hostInformationView setBackgroundColor:[UIColor blackColor]];
    [_hostInformationView setHidden:YES];
    
    [self.view addSubview:self.audienceListView];
    [_audienceListView setFrame:CGRectMake(10, size.height, size.width - 20, ISX ? 334 : 300)];
    [_audienceListView setBackgroundColor:[UIColor blackColor]];
    [_audienceListView setHidden:YES];
    
    [self.view addSubview:self.loginView];
    [_loginView setFrame:CGRectMake(10, size.height, size.width - 20, ISX ? 214 : 180)];
    [_loginView setBackgroundColor:[UIColor blackColor]];
    [_loginView setHidden:YES];
    
    [self.view addSubview:self.giftListView];
    [_giftListView setFrame:CGRectMake(10, size.height, size.width - 20, ISX ? 274 : 240)];
//    [_giftListView setBackgroundColor:[UIColor blackColor]];
    [_giftListView setHidden:YES];
    
    [self registerClass:[RCCRTextMessageCell class]forCellWithReuseIdentifier:textCellIndentifier];
    [self registerClass:[RCCRTextMessageCell class]forCellWithReuseIdentifier:startAndEndCellIndentifier];
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

- (RCCRLoginView *)loginView {
    if (!_loginView) {
        _loginView = [[RCCRLoginView alloc] init];
//        [_loginView setAlpha:0.8];
        [_loginView setDelegate:self];
    }
    return _loginView;
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
