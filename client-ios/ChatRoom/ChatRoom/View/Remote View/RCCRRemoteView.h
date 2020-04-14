//
//  RCCRRemoteView.h
//  ChatRoom
//
//  Created by 孙承秀 on 2019/8/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCCRRemoteCollectionView.h"
#import "RCCRRemoteModel.h"
NS_ASSUME_NONNULL_BEGIN
@protocol RCCRRemoteViewDelegate;

@interface RCCRRemoteView : UIView<RCCRRemoteViewDelegate>

/// 远端试图
@property(nonatomic , strong)RCCRRemoteCollectionView *remoteHostView;

/// 代理
@property(nonatomic , assign)id<RCCRRemoteViewDelegate> delegate;

/// 覆盖
/// @param dataSources 覆盖远端 collectionView 所有数据源
- (void)setDataSources:(NSArray <RCCRRemoteModel *>*)dataSources;

/// 尾插
/// @param models 尾插数据
- (void)pushBackDatas:(NSArray <RCCRRemoteModel *>*)models;

/// 批量删除数据根据 ids
/// @param userIds 要删除的 ids
- (void)deleteDataWithUserIds:(NSArray *)userIds;

/// 批量删除数据根据 streams
/// @param streams 要删除的数据
- (void)deleteDataWithStreams:(NSArray <RongRTCAVInputStream *>*)streams;

/// 更新指定位置的数据
/// @param indexPath 指定位置
/// @param model 要替换位置的数据
- (void)updateIndexPath:(NSIndexPath *)indexPath withModel:(RCCRRemoteModel *)model;

/// 根据有人进入来更新名字
/// @param arr 所有名字
- (void)updateNamesWithWelcome:(NSArray *)arr;

/// 主播通知更新名字
/// @param arr 所有主播
- (void)hostNotiUpdateNames:(NSArray *)arr;
@end

NS_ASSUME_NONNULL_END
