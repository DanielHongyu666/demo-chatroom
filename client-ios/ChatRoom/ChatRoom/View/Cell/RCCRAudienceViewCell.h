//
//  RCCRAudienceViewCell.h
//  ChatRoom
//
//  Created by RongCloud on 2018/5/17.
//  Copyright © 2018年 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCCRAudienceModel.h"
@protocol RCCRAudienceViewCellDelegate;
@interface RCCRAudienceViewCell : UITableViewCell

- (void)setDataModel:(RCCRAudienceModel *)model;

/**
 delegate
 */
@property(nonatomic , weak)id <RCCRAudienceViewCellDelegate> delegate;


@end
@protocol RCCRAudienceViewCellDelegate <NSObject>

- (void)didSelectInviteAudienceBtn:(RCCRAudienceModel *)model;

@end
