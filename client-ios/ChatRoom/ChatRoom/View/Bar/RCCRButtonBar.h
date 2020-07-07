//
//  RCCRButtonBar.h
//  ChatRoom
//
//  Created by 孙承秀 on 2020/4/14.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,RCCRButtonBarType) {
    RCCRButtonBarTypeHost = 0, // 主播
    RCCRButtonBarTypeNormal, // 观众
};
typedef NS_ENUM(NSInteger,RCCRButtonType) {
    RCCRButtonTypeMic = 0,// 麦克风
    RCCRButtonTypeSpeaker , // 扬声器
    RCCRButtonTypeCamera , // 摄像头
    RCCRButtonTypeFile , // 文件
    RCCRButtonTypeCDN , // CDN
};
NS_ASSUME_NONNULL_BEGIN
@protocol RCCRButtonBarDelegate;
@interface RCCRButtonBar : UIView
- (CGSize)getSise;
- (void)reloadData:(RCCRButtonBarType)type;

/**
 delegate
 */
@property(nonatomic , weak) id <RCCRButtonBarDelegate>delegate;

@end
@protocol RCCRButtonBarDelegate <NSObject>

- (void)didTouchButton:(UIButton *)btn index:(RCCRButtonType)index;

@end
NS_ASSUME_NONNULL_END
