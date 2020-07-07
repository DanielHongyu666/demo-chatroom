//
//  RCCRPortraitCollectionViewCell.m
//  ChatRoom
//
//  Created by RongCloud on 2018/5/10.
//  Copyright © 2018年 rongcloud. All rights reserved.
//

#import "RCCRPortraitCollectionViewCell.h"

@implementation RCCRPortraitCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.portaitView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        self.portaitView.layer.cornerRadius = 35/2.0;
        self.portaitView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.portaitView];
    }
    return self;
}

- (void)setDataModel:(RCCRAudienceModel *)model {
    [self.portaitView setImage:[UIImage imageNamed:model.audiencePortrait]];
}

@end
