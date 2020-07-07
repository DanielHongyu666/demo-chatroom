//
//  RCCRGiftNumberLabel.h
//  ChatRoom
//
//  Created by RongCloud on 2018/5/29.
//  Copyright © 2018年 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCCRGiftNumberLabel : UILabel

/**
 描多粗的边
 */
@property (nonatomic, assign) NSInteger outLineWidth;

/**
 外轮颜色
 */
@property (nonatomic, strong) UIColor *outLinetextColor;

/**
 里面字体默认颜色
 */
@property (nonatomic, strong) UIColor *labelTextColor;

@end
