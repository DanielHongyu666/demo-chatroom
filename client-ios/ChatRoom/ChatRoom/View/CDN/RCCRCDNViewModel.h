//
//  RCCRCDNViewModel.h
//  ChatRoom
//
//  Created by 孙承秀 on 2020/5/26.
//  Copyright © 2020 罗骏. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCCRCDNViewModel : NSObject
/**
 dataSources
 */
@property(nonatomic , strong , readonly)NSMutableArray *datas;

/// 添加数据，返回 index
/// @param obj 数据
- (NSUInteger)addObject:(NSDictionary *)obj;
- (NSDictionary *)removeObjAtIndex:(NSUInteger )index;
@end

NS_ASSUME_NONNULL_END
