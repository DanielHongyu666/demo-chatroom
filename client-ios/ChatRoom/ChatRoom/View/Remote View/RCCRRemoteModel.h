//
//  RCCRRemoteModel.h
//  ChatRoom
//
//  Created by 孙承秀 on 2019/8/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongRTCLib/RongRTCLib.h>
NS_ASSUME_NONNULL_BEGIN

@interface RCCRRemoteModel : NSObject

/**
 remote model
 */
@property(nonatomic , strong , nullable)RongRTCAVInputStream *inputStream;

/**
 is remote
 */
@property(nonatomic , assign)BOOL isLocal;


/**
 userName
 */
@property(nonatomic , copy)NSString *userName;
@end

NS_ASSUME_NONNULL_END
