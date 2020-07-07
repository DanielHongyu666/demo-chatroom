//
//  RCCRCDNViewModel.m
//  ChatRoom
//
//  Created by 孙承秀 on 2020/5/26.
//  Copyright © 2020 罗骏. All rights reserved.
//

#import "RCCRCDNViewModel.h"
#import <UIKit/UIKit.h>
#import <RongRTCLib/RongRTCLib.h>
@interface RCCRCDNViewModel()
/**
 dataSources
 */
@property(nonatomic , strong )NSMutableArray *datas;

/**
 all
 */
@property(nonatomic , strong)NSMutableArray *all;
@end
@implementation RCCRCDNViewModel
-(instancetype)init{
    if (self = [super init]) {
        self.datas = [NSMutableArray array];
        self.all = [NSMutableArray array];
        NSString *filePath = [self dataFilePath];
        if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
            NSArray *arr = [[NSArray alloc] initWithContentsOfFile:filePath];
            self.datas = arr.mutableCopy;
        }
        UIApplication *app = [UIApplication sharedApplication];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:app];
        
    }
    return self;
}
-(NSUInteger)addObject:(NSDictionary *)obj{
    @synchronized (self) {
        if (obj) {
            [self.datas insertObject:obj atIndex:0];
        }
    }
    NSLog(@"%@",@(self.datas.count));
    return  0 ;
}
- (NSDictionary *)removeObjAtIndex:(NSUInteger)index{
    @synchronized (self) {
        NSDictionary *cdn = self.datas[index];
        [self.datas removeObjectAtIndex:index];
        return cdn;
    }
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self writeDataToFile];
}
-(NSString *)dataFilePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"data.plist"];
}
-(void)applicationWillResignActive:(NSNotification *)notification{
    
    [self writeDataToFile];
}
- (void)writeDataToFile{
    NSString *filePath = [self dataFilePath];
    [self.datas writeToFile:filePath atomically:YES];
}
@end
