//
//  RCBaseButton.h
//  RongEnterpriseApp
//
//  Created by 孙承秀 on 2017/10/19.
//  Copyright © 2017年 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#define weakify(object) autoreleasepool {} __weak typeof(object)weak##object = object;
#define strongify(object) autoreleasepool {} __strong typeof(object)strong##self = weak##object;
@interface RCButton : UIButton

/**
 button指针
 */
- (void)makeConfig:(void (^)(RCButton *btn))btn;
/**
 指针btn
 */
-(RCButton *)btn;
/**
 设置文字位置
 */
- (RCButton *(^)(NSTextAlignment ))textAlignment;
/**
 设置按钮文字颜色
 */
-(RCButton *(^)(UIColor *,UIControlState state))titleColor;
/**
 设置按钮背景颜色
 */
-(RCButton *(^)(UIColor *))backColor;
/**
 设置按钮图片
 */
-(RCButton *(^)(UIImage * , UIControlState))image;
/**
 设置按钮图片
 */
-(RCButton *(^)(NSString * , UIControlState))titleText;
/**
 设置圆角
 */
-(RCButton *(^)(CGFloat ))cornerRadiusNumber;
/**
 设置字体大小
 */
-(RCButton *(^)(UIFont *))titleFont;
/**
 添加点击方法
 */
-(RCButton *(^)( id , SEL ))addTarget;
@end
