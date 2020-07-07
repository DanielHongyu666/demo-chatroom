//
//  RCCRButtonBar.m
//  ChatRoom
//
//  Created by 孙承秀 on 2020/4/14.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCCRButtonBar.h"
#import "RCCRButtonModel.h"
#import "RCButton.h"
#import "Masonry.h"
@interface RCCRButtonBar()

/**
 datas
 */
@property(nonatomic , strong)NSMutableArray *datas;

@end
@implementation RCCRButtonBar
-(instancetype)init{
    if (self = [super init]) {
        NSMutableArray *arr = [self getDatas];
        self.datas = arr.mutableCopy;
        [self addSubButtons];
    }
    return self;
}
- (void)addSubButtons{
    for (int i = 0 ; i < self.datas.count;i++) {
        RCCRButtonModel *model = self.datas[i];
        RCButton *btn = [[RCButton alloc] init];
        [self addSubview:btn];
        [btn setImage:[UIImage imageNamed:model.imageName] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:model.selectImageName] forState:UIControlStateSelected];
        btn.addTarget(self,@selector(didTouchBtn:));
        btn.tag = [model.tag intValue];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left);
            make.width.mas_equalTo(self.mas_width);
            make.height.mas_equalTo(self.mas_width);
            make.top.mas_equalTo(self.mas_top).offset((i * 36 ) + i * 10);
        }];
    }
}
- (void)reloadData:(RCCRButtonBarType)type{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[RCButton class]]) {
            RCButton *btn = (RCButton *)view;
            btn.hidden = (int)type;
#ifdef DEBUG
            if (btn.tag == 1) {
                btn.hidden = NO;
            }
#endif
        }
    }
}
- (CGSize)getSise{
    NSInteger cout = self.datas.count;
    CGFloat height = (cout -1) * 10 + cout * 36;
    CGSize size = CGSizeMake(36, height);
    return size;
}
- (NSMutableArray *)getDatas{
    NSMutableArray *modesArray = [NSMutableArray arrayWithCapacity:1];
    NSArray *dataArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RCCRSelectPlist.plist" ofType:nil]];
    NSInteger count = dataArray.count;
    for (int i = 0 ; i < count; i ++) {
        NSDictionary *dict = dataArray[i] ;
        RCCRButtonModel *model = [[RCCRButtonModel alloc] init];
        NSString *imageName  = dict[@"imageName"];
        NSString *selectimageName  = dict[@"selectImageName"];
        NSString *tag = dict[@"tag"];
        model.imageName = imageName;
        model.selectImageName = selectimageName;
        model.tag = tag;
        [modesArray addObject:model];
    }
    
    return modesArray;
}
- (void)didTouchBtn:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTouchButton:index:)]) {
        [self.delegate didTouchButton:btn index:btn.tag];
    }
}
@end
