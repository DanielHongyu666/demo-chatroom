//
//  RCCRRemoteView.m
//  ChatRoom
//
//  Created by 孙承秀 on 2019/8/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCCRRemoteView.h"
#import "RCCRAudienceModel.h"
#import "RCCRRemoteViewCellCollectionViewCell.h"
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define LOCK dispatch_semaphore_wait(_sem, DISPATCH_TIME_FOREVER);
#define UNLOCK dispatch_semaphore_signal(_sem);
@implementation RCCRRemoteView
{
    dispatch_semaphore_t _sem;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _sem = dispatch_semaphore_create(1);
       [self initSubviews];
    }
    return self;
}

- (void)initSubviews{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(self.frame.size.height - 6, self.frame.size.height - 6);;
    layout.minimumInteritemSpacing = 2;
    layout.minimumLineSpacing = 2;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.remoteHostView = [[RCCRRemoteCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    self.remoteHostView.contentInset = UIEdgeInsetsMake(3, 3, 3, 3);
    self.remoteHostView.showsHorizontalScrollIndicator = NO;
    self.remoteHostView.showsVerticalScrollIndicator = NO;
    self.remoteHostView.backgroundColor = [UIColor clearColor];
    self.remoteHostView.remoteViewDelegate = self;
    [self addSubview:self.remoteHostView];
}
-(void)setDataSources:(NSArray *)dataSources{
    LOCK;
    NSLog(@"remote view set datasource ：%@",dataSources);
    self.remoteHostView.dataSources = dataSources.mutableCopy;
    [self.remoteHostView reloadData];
    UNLOCK;
}
-(void)pushBackDatas:(NSArray<RCCRRemoteModel *> *)models{
    LOCK;
    NSInteger index = self.remoteHostView.dataSources.count - 1;
    NSMutableArray *arr = [NSMutableArray array];
    NSMutableArray *reloadArr = [NSMutableArray array];
    // 这地方加排重是为了演示适配有的人代码UI处理有问题，所以循环一下，如果自己的数据源处理没有问题，数据处理没有问题，保证UI显示没有问题，可以去掉下面的循环，直接 insertItemsAtIndexPaths 就行，不需要reload旧的数据
    for (NSInteger i = 0 ; i < models.count; i ++) {
        RCCRRemoteModel *model = models[i];
        BOOL has = NO;
        int oriIndex = 0;
        for (RCCRRemoteModel *omodel in self.remoteHostView.dataSources) {
            NSLog(@"--------ori user id : %@",omodel.inputStream.userId);
            if ([omodel.inputStream.userId isEqualToString:model.inputStream.userId] && [omodel.inputStream.tag isEqualToString:model.inputStream.tag] ) {
                has = YES;
                oriIndex = [self.remoteHostView.dataSources indexOfObject:omodel];
            }
        }
        if (!has) {
            [self.remoteHostView.dataSources addObject:model];
            NSLog(@"--------add user id : %@",model.inputStream.userId);
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index + i + 1 inSection:0];
            [arr addObject:indexPath];
        } else {
            NSLog(@"--------has user id : %@",model.inputStream.userId);
            NSLog(@"ori index %ld",oriIndex);
            [self.remoteHostView.dataSources replaceObjectAtIndex:oriIndex withObject:model];
            [reloadArr addObject:[NSIndexPath indexPathForRow:oriIndex inSection:0]];
            for (RCCRRemoteModel *omodel in self.remoteHostView.dataSources) {
                NSLog(@"#####ori user id : %@",omodel.inputStream.userId);
              
            }
        }
    }
    
    [self.remoteHostView insertItemsAtIndexPaths:arr];
    [self.remoteHostView reloadItemsAtIndexPaths:reloadArr];
    UNLOCK;
}
-(RCCRRemoteViewCellCollectionViewCell *)cellWithModel:(RCCRRemoteModel *)model{
    NSUInteger index = [self.remoteHostView.dataSources indexOfObject:model];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    RCCRRemoteViewCellCollectionViewCell *cell  = [self.remoteHostView cellForItemAtIndexPath:indexPath];
    return cell;
}
-(NSArray *)deleteDataWithUserIds:(NSArray *)userIds{
    LOCK;
    NSLog(@"remote view delete datas ：%@",userIds);
    NSMutableArray *arr = self.remoteHostView.dataSources.mutableCopy;
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSMutableArray *cells = [NSMutableArray array];
    NSInteger count = arr.count;
    for (NSString *userId in userIds) {
      for (NSInteger i = 0 ; i < count; i ++) {
          RCCRRemoteModel *model = arr[i];
          if ([model.inputStream.userId isEqualToString:userId]) {
              NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
              if (indexPath != nil) {
                  [indexPaths addObject:indexPath];
                  [cells addObject:model];
                  model.inputStream = nil;
                  [self.remoteHostView.dataSources removeObject:model];
              }
          }
      }
    }
//    self.remoteHostView.dataSources = arr.mutableCopy;
    [self.remoteHostView deleteItemsAtIndexPaths:indexPaths];
    UNLOCK;
    return cells.copy;
}
-(void)deleteDataWithStreams:(NSArray<RCRTCInputStream *> *)streams{
    LOCK;
    NSLog(@"remote view delete datas with streams ：%@",@(streams.count));
    NSMutableArray *arr = self.remoteHostView.dataSources.mutableCopy;
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (RCRTCInputStream *stream in streams) {
        for (NSInteger i = 0 ; i < self.remoteHostView.dataSources.count ; i ++){
            RCCRRemoteModel *model = self.remoteHostView.dataSources[i];
            if ([model.inputStream isKindOfClass:[RCRTCInputStream class]]) {
                RCRTCInputStream *inputStream = (RCRTCInputStream *)model.inputStream;
                if ([inputStream.userId isEqualToString:stream.userId] && inputStream.mediaType == stream.mediaType && [inputStream.streamId isEqualToString:stream.streamId]&&[stream.tag isEqualToString:inputStream.tag]) {
                    [arr removeObject:model];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                    if (indexPath!=nil) {
                        [indexPaths addObject:indexPath];
                    }
                }
            }
            
        }
    }
    self.remoteHostView.dataSources = arr.mutableCopy;
    [self.remoteHostView deleteItemsAtIndexPaths:indexPaths];
    UNLOCK;
}
-(void)updateNamesWithWelcome:(NSArray *)arr{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (RCCRRemoteModel *model in self.remoteHostView.dataSources) {
            if (!model.userName) {
                for (RCCRAudienceModel *userInfo in arr) {
                    if ([userInfo.userId isEqualToString:model.inputStream.userId]) {
                        model.userName = userInfo.audienceName;
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.remoteHostView.dataSources indexOfObject:model] inSection:0];
                        if (indexPath != nil) {
                            [indexPaths addObject:indexPath];

                        }
                    }
                }
            }
        }
        
        [self.remoteHostView reloadItemsAtIndexPaths:indexPaths];
    });
    
}
-(void)hostNotiUpdateNames:(NSArray *)arr{
    dispatch_async(dispatch_get_main_queue(), ^{
           NSMutableArray *indexPaths = [NSMutableArray array];
           for (RCCRRemoteModel *model in self.remoteHostView.dataSources) {
               if (!model.userName) {
                   for (RCUserInfo *userInfo in arr) {
                       if ([userInfo.userId isEqualToString:model.inputStream.userId]) {
                           model.userName = userInfo.name;
                           NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.remoteHostView.dataSources indexOfObject:model] inSection:0];
                           if (indexPath != nil) {
                                [indexPaths addObject:indexPath];

                           }
                       }
                   }
               }
           }
           
           [self.remoteHostView reloadItemsAtIndexPaths:indexPaths];
       });
}
-(void)updateIndexPath:(NSIndexPath *)indexPath withModel:(RCCRRemoteModel *)model{
    LOCK;
    NSLog(@"lets update %@",@(indexPath.row));
    if (indexPath.row < self.remoteHostView.dataSources.count) {
        NSLog(@"begin to update %@",@(indexPath.row));
        [self.remoteHostView.dataSources replaceObjectAtIndex:indexPath.row withObject:model];
        [self.remoteHostView reloadItemsAtIndexPaths:@[indexPath]];
    }
    UNLOCK;
}

-(void)didSelectCell:(RCCRRemoteViewCellCollectionViewCell *)cell model:(RCCRRemoteModel *)model indexPath:(NSIndexPath *)indexPath{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCell:model:indexPath:)]) {
        [self.delegate didSelectCell:cell model:model indexPath:indexPath];;
    }
}
@end
