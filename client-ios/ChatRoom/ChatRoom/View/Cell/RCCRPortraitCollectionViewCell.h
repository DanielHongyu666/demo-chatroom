//
//  RCCRPortraitCollectionViewCell.h
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/10.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCCRAudienceModel.h"

@interface RCCRPortraitCollectionViewCell : UICollectionViewCell

@property(nonatomic,strong) UIImageView *portaitView;

- (void)setDataModel:(RCCRAudienceModel *)model;

@end
