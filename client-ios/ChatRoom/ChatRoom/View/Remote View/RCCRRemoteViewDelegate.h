//
//  RCCRRemoteViewDelegate.h
//  ChatRoom
//
//  Created by 孙承秀 on 2019/9/10.
//  Copyright © 2019 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCCRRemoteModel.h"
#import "RCCRRemoteViewCellCollectionViewCell.h"
NS_ASSUME_NONNULL_BEGIN

@protocol RCCRRemoteViewDelegate <NSObject>
-(void)didSelectCell:(RCCRRemoteViewCellCollectionViewCell *)cell model:(RCCRRemoteModel *)model indexPath:(nonnull NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
