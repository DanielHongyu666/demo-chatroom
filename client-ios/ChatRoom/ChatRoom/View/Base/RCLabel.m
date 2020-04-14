//
//  RCLabel.m
//  RongEnterpriseApp
//
//  Created by 孙承秀 on 2017/10/19.
//  Copyright © 2017年 rongcloud. All rights reserved.
//

#import "RCLabel.h"
@interface RCLabel()

/**
 fillColor
 */
@property(nonatomic , strong)UIColor *fillColor;
/**
 leftLayer
 */
@property(nonatomic , strong)CAShapeLayer *leftLayer;
/**
 rightLayer
 */
@property(nonatomic , strong)CAShapeLayer *rightLayer;
@end
@implementation RCLabel
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.fillColor = [UIColor greenColor];
       
    }
    return self;
}
-(void)makeConfig:(void (^)(RCLabel *lab))lab{
    @weakify(self);
    lab(weakself);
}
-(RCLabel *(^)(NSString *))labelText{
    return ^ RCLabel *(NSString *text){
        self.text = text;
        return self;
    };
}
-(RCLabel *(^)(UIColor *))titleColor{
    return ^ RCLabel *(UIColor *color){
        [self setTextColor:color];
        return self;
    };
}
-(RCLabel *(^)(UIColor *))backGroundColor{
    return ^ RCLabel *(UIColor *color){
        [self setBackgroundColor:color];
        return self;
    };
}
-(RCLabel *(^)(NSInteger))numberLines{
    return ^ RCLabel *(NSInteger number){
        self.numberOfLines = number;
        return self;
    };
}
-(RCLabel *(^)(NSLineBreakMode))lineMode{
    return ^ RCLabel *(NSLineBreakMode mode){
        self.lineBreakMode = mode;
        return self;
    };
}
-(RCLabel *(^)(UIFont *))titleFont{
    return ^ RCLabel *(UIFont * font){
        [self setFont:font];
        return self;
    };
}
-(RCLabel *(^)(CGFloat))cornerValue{
    return ^ RCLabel *(CGFloat value){
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = value;
        return self;
    };
}
-(RCLabel *(^)(NSTextAlignment))alignment{
    return ^ RCLabel *(NSTextAlignment textalignment){
        self.textAlignment = textalignment;
        return self;
    };
}
#pragma mark --- 不带动画的progress
-(void)setProgress:(CGFloat)progress{
    _progress=progress;
    [self setNeedsDisplay];
}
-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    [_fillColor set];
    CGRect newRect=rect;
    newRect.size.width=rect.size.width*_progress;
    UIRectFillUsingBlendMode(newRect, kCGBlendModeSourceIn);
    
}
#pragma mark -- 带动画的progress
-(void)setLeftScale:(CGFloat)leftScale{
    _leftScale = leftScale;
    [self layoutIfNeeded];
    [self.layer addSublayer:self.leftLayer];
    UIRectCorner rectCorner = UIRectCornerAllCorners;
    if (leftScale >= 1.0 ) {
        rectCorner = UIRectCornerAllCorners;
    }
    else{
        rectCorner = UIRectCornerTopLeft | UIRectCornerBottomLeft;
    }
    CGFloat height  = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    UIBezierPath *bezierPath1 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 0, height) byRoundingCorners:rectCorner cornerRadii:CGSizeMake(height / 2, height / 2)];
    UIBezierPath *bezierPath2 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, leftScale * width, height) byRoundingCorners:rectCorner cornerRadii:CGSizeMake(height / 2, height / 2)];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration = 0.8;
    animation.fromValue = (__bridge id _Nullable)(bezierPath1.CGPath);
    animation.toValue = (__bridge id _Nullable)(bezierPath2.CGPath);
    [self.leftLayer addAnimation:animation forKey:nil];
}
+ (NSMutableAttributedString *)setAttributeString:(NSString*)text{
    if (text!=nil) {
        NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc]initWithString:text];
        
        [attributeText addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],
                                       NSForegroundColorAttributeName:[UIColor blackColor]}
                               range:NSMakeRange(0, text.length)];
        NSMutableParagraphStyle *stype = [[NSMutableParagraphStyle alloc]init];
        stype.lineSpacing = 3;
        stype.alignment = NSTextAlignmentLeft;
        [attributeText addAttribute:NSParagraphStyleAttributeName value:stype range:NSMakeRange(0, attributeText.length)];
        return attributeText;
    }
    return nil;
}
-(CAShapeLayer *)leftLayer{
    if (!_leftLayer) {
        _leftLayer = [CAShapeLayer layer];
         _leftLayer.fillColor = [UIColor greenColor].CGColor;
    }
    return _leftLayer;
}
@end
