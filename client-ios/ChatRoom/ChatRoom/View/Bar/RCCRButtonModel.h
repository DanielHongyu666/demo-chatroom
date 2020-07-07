//
//  RCCRButtonModel.h
//  ChatRoom
//
//  Created by 孙承秀 on 2020/4/14.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCCRButtonModel : NSObject

/**
 imageName
 */
@property(nonatomic , copy)NSString *imageName;

/**
 imageName
 */
@property(nonatomic , copy)NSString *selectImageName;

/**
 tag
 */
@property(nonatomic , copy)NSString *tag;
@end

NS_ASSUME_NONNULL_END
