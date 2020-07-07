//
//  RCCRCDNSelectModel.h
//  ChatRoom
//
//  Created by 孙承秀 on 2020/5/29.
//  Copyright © 2020 罗骏. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCCRCDNSelectModel : NSObject
/**
 appname
 */
@property(nonatomic , copy)NSString *appName;

/**
 streamName
 */
@property(nonatomic , copy)NSString *streamName;

/**
 cdn id
 */
@property(nonatomic , copy)NSString *cdnId;

/**
 roomId
 */
@property(nonatomic , copy)NSString *roomId;
@end

NS_ASSUME_NONNULL_END
