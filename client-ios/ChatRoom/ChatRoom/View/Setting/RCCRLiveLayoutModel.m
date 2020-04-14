//
//  RCCRLiveLayoutModel.m
//  ChatRoom
//
//  Created by 孙承秀 on 2019/12/12.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCCRLiveLayoutModel.h"

@implementation RCCRLiveLayoutModel
@synthesize layoutType = _layoutType;
-(instancetype)initWithType:(RCCRLiveLayoutType)layoutType{
    if (self = [super init]) {
        _layoutType = layoutType;
    }
    return self;
}
@end
