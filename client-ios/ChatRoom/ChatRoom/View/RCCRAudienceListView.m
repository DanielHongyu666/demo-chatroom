//
//  RCCRAudienceListView.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/11.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "RCCRAudienceListView.h"
#import "RCCRAudienceViewCell.h"

static NSString *reusableCellWithIdentifier = @"RCCRAudienceTableViewCell";

@interface RCCRAudienceListView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray<RCCRAudienceModel *> *audienceArr;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITableView *audienceTableView;

@end

@implementation RCCRAudienceListView

- (instancetype)initWithAudiences:(NSArray *)audienceArr {
    self = [super init];
    if (self) {
        self = [super init];
        self.audienceArr = [audienceArr copy];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self initializedSubViews];
}

- (void)initializedSubViews {
    [self addSubview:self.titleLabel];
    [_titleLabel setFrame:CGRectMake(10, 20, 100, 20)];
    
    [self addSubview:self.audienceTableView];
    [_audienceTableView setFrame:CGRectMake(0, 50, self.bounds.size.width, self.bounds.size.height - 50)];
}

- (void)setModelArray:(NSArray<RCCRAudienceModel *> *)modelArray {
    self.audienceArr = [modelArray copy];
    [_audienceTableView reloadData];
}

#pragma mark - UITableView delegate/dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    return self.audienceArr.count == 0 ? 20 : self.audienceArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCCRAudienceViewCell *cell = [self.audienceTableView
                                      dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell == nil) {
        cell = [[RCCRAudienceViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableCellWithIdentifier];
    }

    RCCRAudienceModel * model = self.audienceArr[indexPath.row];
    [cell setDataModel:model];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"点击了关注列表");
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
        [_titleLabel setNumberOfLines:1];
        [_titleLabel setTextColor:[UIColor whiteColor]];
        [_titleLabel setText:@"在线用户"];
    }
    return  _titleLabel;
}

- (UITableView *)audienceTableView {
    if (!_audienceTableView) {
        _audienceTableView = [[UITableView alloc] init];
        [_audienceTableView setDelegate:self];
        [_audienceTableView setDataSource:self];
        [_audienceTableView setBackgroundColor: [UIColor blackColor]];
        [_audienceTableView setSeparatorColor:[UIColor whiteColor]];
    }
    return _audienceTableView;
}

@end
