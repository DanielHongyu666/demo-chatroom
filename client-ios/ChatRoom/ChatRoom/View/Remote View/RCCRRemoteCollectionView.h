//
//  RCCRRemoteCollectionView.h
//  ChatRoom
//
//  Created by 孙承秀 on 2019/8/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCCRRemoteViewCellCollectionViewCell.h"
#import "RCCRRemoteModel.h"
#import "RCCRRemoteViewDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCCRRemoteCollectionView : UICollectionView <UICollectionViewDataSource , UICollectionViewDelegate>

/**
 data source
 */
@property(nonatomic , strong)NSMutableArray <RCCRRemoteModel *>*dataSources;

/**
 deledate
 */
@property(nonatomic , weak)id <RCCRRemoteViewDelegate> remoteViewDelegate;

@end

NS_ASSUME_NONNULL_END
