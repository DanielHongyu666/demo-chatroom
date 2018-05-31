//
//  RCCRTextMessageCell.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/22.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "RCCRTextMessageCell.h"
#import <RongIMKit/RongIMKit.h>
#import "RCCRManager.h"
#import "RCChatroomWelcome.h"
#import "RCChatroomFollow.h"
#import "RCChatroomLike.h"

#define RCCRText_HEXCOLOR(rgbValue)                                                                                             \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0                                               \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0                                                  \
blue:((float)(rgbValue & 0xFF)) / 255.0                                                           \
alpha:1.0]

@interface RCCRTextMessageCell ()

@end

@implementation RCCRTextMessageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initializedSubViews];
    }
    return self;
}

- (void)initializedSubViews {
    [self addSubview:self.textLabel];
    [_textLabel setFrame:CGRectMake(10, 0, self.bounds.size.width, self.bounds.size.height)];
}

- (void)setDataModel:(RCCRMessageModel *)model {
    [super setDataModel:model];
    [self updateUI:model];
}

- (void)updateUI:(RCCRMessageModel *)model {
    if ([model.content isMemberOfClass:[RCChatroomWelcome class]]) {
        RCUserInfo *userInfo = [[RCCRManager sharedRCCRManager] getUserInfo:self.model.senderUserId];
        NSString *userName = userInfo.name;
        NSString *localizedMessage = @"进入直播间";
        NSString *str =[NSString stringWithFormat:@"%@ %@",userName,localizedMessage];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
        
        [attributedString addAttribute:NSForegroundColorAttributeName value:(RCCRText_HEXCOLOR(0x3ce1ff)) range:[str rangeOfString:userName]];
        [attributedString addAttribute:NSForegroundColorAttributeName value:(RCCRText_HEXCOLOR(0xffffff)) range:[str rangeOfString:localizedMessage]];
        [self.textLabel setAttributedText:attributedString.copy];
        return;
    } else if ([model.content isMemberOfClass:[RCChatroomFollow class]]) {
        RCUserInfo *userInfo = [[RCCRManager sharedRCCRManager] getUserInfo:self.model.senderUserId];
        NSString *userName = userInfo.name;
        NSString *localizedMessage = @"关注了主播";
        NSString *str =[NSString stringWithFormat:@"%@ %@",userName,localizedMessage];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
        
        [attributedString addAttribute:NSForegroundColorAttributeName value:(RCCRText_HEXCOLOR(0x3ce1ff)) range:[str rangeOfString:userName]];
        [attributedString addAttribute:NSForegroundColorAttributeName value:(RCCRText_HEXCOLOR(0xffb83c)) range:[str rangeOfString:localizedMessage]];
        [self.textLabel setAttributedText:attributedString.copy];
        return;
    } else if ([model.content isMemberOfClass:[RCChatroomLike class]]) {
        RCChatroomLike *likeMessage = (RCChatroomLike *)model.content;
        RCUserInfo *userInfo = [[RCCRManager sharedRCCRManager] getUserInfo:self.model.senderUserId];
        NSString *userName = userInfo.name;
        NSString *localizedMessage = [NSString stringWithFormat:@"给主播点了%d个赞",likeMessage.counts];
        NSString *str =[NSString stringWithFormat:@"%@ %@",userName,localizedMessage];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
        
        [attributedString addAttribute:NSForegroundColorAttributeName value:(RCCRText_HEXCOLOR(0x3ce1ff)) range:[str rangeOfString:userName]];
        [attributedString addAttribute:NSForegroundColorAttributeName value:(RCCRText_HEXCOLOR(0xffb83c)) range:[str rangeOfString:localizedMessage]];
        [self.textLabel setAttributedText:attributedString.copy];
        return;
    } else if ([model.content isMemberOfClass:[RCTextMessage class]]) {
        RCTextMessage *textMessage = (RCTextMessage *)self.model.content;
        if (self.model.senderUserId) {
            NSString *localizedMessage = textMessage.content;
            RCUserInfo *userInfo = [[RCCRManager sharedRCCRManager] getUserInfo:self.model.senderUserId];
            NSString *userName = userInfo.name;
            NSString *str =[NSString stringWithFormat:@"%@ %@",userName,localizedMessage];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
            
            [attributedString addAttribute:NSForegroundColorAttributeName value:(RCCRText_HEXCOLOR(0x3ce1ff)) range:[str rangeOfString:userName]];
            [attributedString addAttribute:NSForegroundColorAttributeName value:(RCCRText_HEXCOLOR(0xffb83c)) range:[str rangeOfString:localizedMessage]];
            [self.textLabel setAttributedText:attributedString.copy];
        
        }
    }
}

+ (CGSize)getMessageCellSize:(NSString *)content withWidth:(CGFloat)width{
    CGSize textSize = CGSizeZero;
    textSize.height = textSize.height + 17;
    return textSize;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        [_textLabel setTextAlignment: NSTextAlignmentLeft];
        [_textLabel setTintColor:[UIColor whiteColor]];
    }
    return _textLabel;
}

@end
