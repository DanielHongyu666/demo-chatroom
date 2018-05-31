//
//  RCCRAudienceListView.h
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/11.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCCRAudienceModel.h"

@interface RCCRAudienceListView : UIView

- (instancetype)initWithAudiences:(NSArray *)audienceArr;

- (void)setModelArray:(NSArray<RCCRAudienceModel *> *)modelArray;

@end
