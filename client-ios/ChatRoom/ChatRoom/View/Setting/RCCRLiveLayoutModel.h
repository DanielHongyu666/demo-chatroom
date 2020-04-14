//
//  RCCRLiveLayoutModel.h
//  ChatRoom
//
//  Created by 孙承秀 on 2019/12/12.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger , RCCRLiveLayoutType) {
    /*
     自定义
     */
    RCCRLiveLayoutTypeCustom = 1,
    /*
     悬浮
     */
    RCCRLiveLayoutTypeSuspension,
    /*
     自适应
     */
    RCCRLiveLayoutTypeAdaptive,
    
};
NS_ASSUME_NONNULL_BEGIN

@interface RCCRLiveLayoutModel : NSObject
- (instancetype)initWithType:(RCCRLiveLayoutType)layoutType;
/**
 type
 */
@property(nonatomic , assign )RCCRLiveLayoutType layoutType;

/**
 x
 */
@property(nonatomic , assign)CGFloat x;

/**
 height
 */
@property(nonatomic , assign)CGFloat height;

/**
 width
 */
@property(nonatomic , assign)CGFloat width;

/**
 cro
 */
@property(nonatomic , assign)BOOL customCrop;


/**
 adaptive crop
 */
@property(nonatomic , assign)BOOL adaptiveCrop;

/**
 suspension crop
 */
@property(nonatomic , assign)BOOL suspensionCrop;



@end

NS_ASSUME_NONNULL_END
