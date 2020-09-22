//
//  RCCRLiveHttpManager.h
//  ChatRoom
//
//  Created by RongCloud on 2019/8/31.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

#define RCIM_API_SECRET @""
typedef void(^RCFetchTokenCompletion)(BOOL isSucccess,NSString * _Nullable token);
NS_ASSUME_NONNULL_BEGIN

@interface RCCRLiveHttpManager : NSObject
+(RCCRLiveHttpManager *)sharedManager;

/**
 vc,用于弹框
 */
@property(nonatomic , weak)UIViewController *chatVC;

-(void)fetchTokenWithUserId:(NSString *)userId username:(NSString *)username portraitUri:(NSString *)portraitUri completion:(RCFetchTokenCompletion)completion;
- (void)publish:(NSString *)roomId roomName:(NSString *)roomName liveUrl:(NSString *)liveUrl cover:(NSString *)index completion:(void (^)(BOOL success , NSInteger code))completion;
- (void)query:(NSString *)roomId completion:(void (^)( BOOL isSuccess,NSArray  *_Nullable))completion;
- (void)unpublish:(NSString *)roomId  completion:(void (^)(BOOL success))completion;
- (void)getDemoVersionInfo:(void (^)(NSDictionary *respDict))resp;
- (void)getCDNSupplyListWithRoomId:(NSString *)roomId completion:(void (^)(BOOL success , NSArray *list))completion;
- (void)getCdnListWithRoomId:(NSString *)roomId streamName:(NSString *)streamName appName:(NSString *)appName cdnId:(NSString *)cdnId completion:(void (^)(BOOL success , NSArray *list))completion;
@end

NS_ASSUME_NONNULL_END
