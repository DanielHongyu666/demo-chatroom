//
//  RCBaseLabel.h
//  RongEnterpriseApp
//
//  Created by 孙承秀 on 2017/10/19.
//  Copyright © 2017年 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#define weakify(object) autoreleasepool {} __weak typeof(object)weak##object = object;
#define strongify(object) autoreleasepool {} __strong typeof(object)strong##self = weak##object;
@interface RCLabel : UILabel
/**
 label指针
 */
- (void)makeConfig:(void (^)(RCLabel *lab))lab;
-(RCLabel *(^)(NSString *))labelText;
-(RCLabel *(^)(UIColor *))titleColor;
-(RCLabel *(^)(UIColor *))backGroundColor;
-(RCLabel *(^)(NSInteger))numberLines;
-(RCLabel *(^)(NSLineBreakMode))lineMode;
-(RCLabel *(^)(UIFont *))titleFont;
-(RCLabel *(^)(CGFloat ))cornerValue;
-(RCLabel *(^)(NSTextAlignment ))alignment;
/**
 progress
 */
@property(nonatomic , assign)CGFloat progress;
/**
 可以使用这个基类来设置进度条的效果，左边的进度(从左往右的效果)
 */
@property(nonatomic , assign)CGFloat leftScale;

+ (NSMutableAttributedString *)setAttributeString:(NSString*)text;
@end
