//
//  RCCRRemoteCollectionView.m
//  ChatRoom
//
//  Created by 孙承秀 on 2019/8/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCCRRemoteCollectionView.h"
static NSString * const RCCRRemoteCollectionViewCellId = @"RCCRRemoteCollectionViewCell";
@implementation RCCRRemoteCollectionView 

-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        // 注册cell
           [self registerClass:[RCCRRemoteViewCellCollectionViewCell class] forCellWithReuseIdentifier:RCCRRemoteCollectionViewCellId];
        self.dataSources = [NSMutableArray array];
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCCRRemoteViewCellCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:RCCRRemoteCollectionViewCellId forIndexPath:indexPath];
    RCCRRemoteModel *model = self.dataSources[indexPath.row];
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 4;
    cell.layer.borderWidth = 0.5;
    cell.layer.borderColor = [UIColor whiteColor].CGColor;
    [cell setRemoteModel:model];
    return cell;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    NSLog(@"view class is %@",[touch.view class]);
    if ( [NSStringFromClass([touch.view class]) isEqualToString:@"GLKView"] || [NSStringFromClass([touch.view class]) isEqualToString:@"RCRTCLocalVideoView"]) {
        return YES;
    }
   
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RCCRRemoteViewCellCollectionViewCell *cell = (RCCRRemoteViewCellCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (self.remoteViewDelegate && [self.remoteViewDelegate respondsToSelector:@selector(didSelectCell:model:indexPath:)]) {
        [self.remoteViewDelegate didSelectCell:cell model:self.dataSources[indexPath.row] indexPath:indexPath];;
    }
}

@end
