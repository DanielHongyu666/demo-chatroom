//
//  RCCRSettingBaseTableViewCell.m
//  ChatRoom
//
//  Created by 孙承秀 on 2019/12/4.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCCRSettingBaseTableViewCell.h"
#import "RCCRSettingModel.h"
@implementation RCCRSettingBaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)product:(RCCRSettingModel *)model{
    if (model.layoutModel) {
        self.layoutModel = model.layoutModel;
    }
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"touch custom table view cell");
    if (self.returnDelegate && [self.returnDelegate respondsToSelector:@selector(didTouchCell:)]) {
        [self.returnDelegate didTouchCell:self];
    }
}
@end
