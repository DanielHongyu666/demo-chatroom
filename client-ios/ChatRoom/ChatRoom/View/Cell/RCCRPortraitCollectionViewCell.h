//
//  RCCRPortraitCollectionViewCell.h
//  ChatRoom
//
//  Created by RongCloud on 2018/5/10.
//  Copyright © 2018年 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCCRAudienceModel.h"

@interface RCCRPortraitCollectionViewCell : UICollectionViewCell

@property(nonatomic,strong) UIImageView *portaitView;

- (void)setDataModel:(RCCRAudienceModel *)model;

@end
