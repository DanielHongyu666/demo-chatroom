//
//  RCButton.m
//  RongEnterpriseApp
//
//  Created by 孙承秀 on 2017/10/19.
//  Copyright © 2017年 rongcloud. All rights reserved.
//

#import "RCButton.h"
@interface RCButton()

/*************  按钮文字 ***************/
@property ( nonatomic , copy )NSString *btnTitle;

/*************  按钮文字状态 ***************/
@property ( nonatomic , assign )UIControlState btnTitleState;

/*************  titleColorSate ***************/
@property ( nonatomic , assign )UIControlState btnTitleColorState;

/*************  btnTitleColor ***************/
@property ( nonatomic , strong )UIColor *btnTitleColor;

/*************  image ***************/
@property ( nonatomic , strong )UIImage *selfImage;

/*************  iamgeState ***************/
@property ( nonatomic , assign )UIControlState selfImageState;

/*************  RCEBaseButton ***************/
@property ( nonatomic , strong )RCButton *RCEBaseButton;
@end
@implementation RCButton

-(instancetype)init{
    if (self = [super init]) {
        self.RCEBaseButton = self;
    }
    return self;
}
/**
 button指针
 */
-(void)makeConfig:(void (^)(RCButton *btn))btn{
    @weakify(self);
    btn(weakself);
    
}

/**
 指针btn
 */
-(RCButton *)btn{
    @weakify(self);
    return weakself;
    
}
-(RCButton *(^)(NSString *, UIControlState))titleText{
    return ^ RCButton *(NSString *text , UIControlState state){
        [self setTitle:text forState:state];
        return self;
    };
}

/**
 设置文字位置
 */
- (RCButton *(^)(NSTextAlignment ))textAlignment{
    return ^ RCButton *(NSTextAlignment alignment){
        self.titleLabel.textAlignment = alignment;
        return self;
    };
    
}
/**
 设置按钮文字颜色
 */
-(RCButton *(^)(UIColor *,UIControlState state))titleColor{
    return ^ RCButton *(UIColor *color , UIControlState state){
        [self setTitleColor:color forState:state];
        return self;
    };
}

/**
 设置字体大小
 */
-(RCButton *(^)(UIFont *))titleFont{
    return ^ RCButton *(UIFont *font){
        [self.titleLabel setFont:font];
        return self;
    };
}
/**
 设置按钮背景颜色
 */
-(RCButton *(^)(UIColor *))backColor{
    return ^ RCButton *(UIColor *color){
        [self setBackgroundColor:color];
        return self;
    };
}
/**
 设置按钮文字颜色状态
 */
-(RCButton *(^)(UIControlState ))titleColorState{
    return ^ RCButton *(UIControlState state){
        self.btnTitleColorState = state;
        if (self.btnTitleColor == nil) {
            self.btnTitleColor = [UIColor clearColor];
        }
        [self setTitleColor:self.btnTitleColor forState:state];
        return self;
    };
}
/**
 设置按钮图片
 */
-(RCButton *(^)(UIImage *, UIControlState))image{
    return ^ RCButton *(UIImage *image , UIControlState state){
        [self setImage:image forState:state];
        return self;
    };
}

/**
 设置圆角
 */
-(RCButton *(^)(CGFloat ))cornerRadiusNumber{
    return ^ RCButton *(CGFloat corner){
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = corner;
        return self;
    };
}
/**
 添加点击方法
 */
-(RCButton *(^)( id , SEL ))addTarget{
    return ^ RCButton * (id target , SEL selector){
        [self addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
        return self;
    };
}
- (RCButton *(^) ())SetbuttonImage{
    return ^ RCButton *{
        
        return self;
    };
    
}


@end
