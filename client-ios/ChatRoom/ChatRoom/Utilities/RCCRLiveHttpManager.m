//
//  RCCRLiveHttpManager.m
//  SealRTC
//
//  Created by RongCloud on 2019/8/31.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCCRLiveHttpManager.h"
#include <CommonCrypto/CommonCrypto.h>
#import <UIKit/UIKit.h>
#import <RongIMLib/RongIMLib.h>
#import "RCCRRoomModel.h"
#define kDeviceUUID [[[[UIDevice currentDevice] identifierForVendor] UUIDString] substringToIndex:4]

@interface NSString (CC)
@property (nonatomic,copy,readonly)NSString *sha1;
@end

@implementation NSString (CC)

- (NSString*) sha1
{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    //使用对应的CC_SHA1,CC_SHA256,CC_SHA384,CC_SHA512的长度分别是20,32,48,64
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    //使用对应的CC_SHA256,CC_SHA384,CC_SHA512
    CC_SHA1(data.bytes, data.length, digest);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}


@end


/// 简单网络请求，不适用并封装第三方
@interface RCCRLiveHttpManager ()<NSURLSessionDelegate>
@property (nonatomic,strong)NSURLSession *defaultSession;
@property (nonatomic,strong)NSOperationQueue *queue;
@end

@implementation RCCRLiveHttpManager
+(RCCRLiveHttpManager *)sharedManager{
    static RCCRLiveHttpManager * _manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc]init];
        [_manager configure];
    });
    return _manager;
}

-(void)configure{
    self.queue = [[NSOperationQueue alloc]init];
    self.defaultSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
}
- (void)publish:(NSString *)roomId roomName:(NSString *)roomName liveUrl:(NSString *)liveUrl cover:(NSString *)index completion:(void (^)(BOOL success , NSInteger code))completion{
    NSString *host;
    if ([APPSERVER hasPrefix:@"http"]) {
        host = APPSERVER;
    } else {
        host = [@"https://" stringByAppendingString:APPSERVER];
    }
    NSURL* urlPost = [NSURL URLWithString:[NSString stringWithFormat:@"%@/publish",host]];
    NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:urlPost
                                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                        timeoutInterval:30.0];
    
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *dic = @{@"roomId":roomId?roomId:@"", @"roomName":roomName?roomName:@"",@"mcuUrl":liveUrl?liveUrl:@"",@"pubUserId":[RCIMClient sharedRCIMClient].currentUserInfo.userId , @"coverIndex":index?index:@"0"};
    NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
    request.HTTPBody = data;
    NSURLSessionTask *task = [self.defaultSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error && data != nil) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableContainers) error:nil];
            NSInteger code = [dic[@"code"] integerValue];
            if (completion) {
                completion(YES,code);
            }
            if (code != 0) {
                [self alert:code];
            }
        } else {
            [self alert:[self getCode:response error:error]];
            if (completion) {
                completion(NO,[self getCode:response error:error]);
            }
        }
    }];
    [task  resume];
}
- (void)getCDNSupplyListWithRoomId:(NSString *)roomId completion:(void (^)(BOOL success , NSArray *list))completion{
    NSString *host;
    if ([RCCDNSERVER hasPrefix:@"http"]) {
        host = RCCDNSERVER;
    } else {
        host = [@"https://" stringByAppendingString:RCCDNSERVER];
    }
    NSURL* urlPost = [NSURL URLWithString:[NSString stringWithFormat:@"%@/cdnsupply",host]];
    NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:urlPost
                                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                        timeoutInterval:30.0];
    
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *dic = @{@"roomId":roomId?roomId:@""};
    NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
    request.HTTPBody = data;
    NSURLSessionTask *task = [self.defaultSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error == nil && data != nil) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableContainers) error:nil];
            NSInteger code = [dic[@"code"] integerValue];
            if (completion) {
                NSArray *list = dic[@"cdnSupplyList"];
                completion(YES ,list);
            }
            if (code != 0) {
                [self alert: code];
            }
        } else {
            [self alert:[self getCode:response error:error]];
            if (completion) {
                completion(NO,@[]);
            }
        }
        
    }];
    [task  resume];
}
- (void)getCdnListWithRoomId:(NSString *)roomId streamName:(NSString *)streamName appName:(NSString *)appName cdnId:(NSString *)cdnId completion:(void (^)(BOOL success , NSArray *list))completion{
    NSString *host;
    if ([RCCDNSERVER hasPrefix:@"http"]) {
        host = RCCDNSERVER;
    } else {
        host = [@"https://" stringByAppendingString:RCCDNSERVER];
    }
    NSURL* urlPost = [NSURL URLWithString:[NSString stringWithFormat:@"%@/cdnurl",host]];
    NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:urlPost
                                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                        timeoutInterval:30.0];
    
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *dic = @{@"roomId":roomId?roomId:@"",@"appName":appName?appName:@"",@"streamName":streamName?streamName:@"",@"cdnId":cdnId?cdnId:@""};
    NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
    request.HTTPBody = data;
    NSURLSessionTask *task = [self.defaultSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ( error == nil && data != nil) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableContainers) error:nil];
            NSInteger code = [dic[@"code"] integerValue];
            if (completion) {
                NSArray *list = dic[@"cdnList"];
                completion(YES ,list);
            }
            if (code != 0) {
                [self alert:code];
            }
        } else {
            [self alert:[self getCode:response error:error]];
            if (completion) {
                completion(NO,@[]);
            }
        }
       
    }];
    [task  resume];
}
- (void)query:(NSString *)roomId completion:(void (^)( BOOL isSuccess,NSArray  *_Nullable))completion{
    NSString *host;
    if ([APPSERVER hasPrefix:@"http"]) {
        host = APPSERVER;
    } else {
        host = [@"https://" stringByAppendingString:APPSERVER];
    }
    NSURL* urlPost = [NSURL URLWithString:[NSString stringWithFormat:@"%@/query",host]];
    NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:urlPost
                                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                        timeoutInterval:30.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *dic = @{};
    NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
    request.HTTPBody = data;
    NSURLSessionTask *task = [self.defaultSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data != nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSInteger code = [dict[@"code"] integerValue];
            BOOL success = [dict[@"code"] boolValue];
            if (error || success) {
                if (completion) {
                    completion(NO,nil);
                }
             
                [self alert:code > 0 ? code : error.code ];
                
            } else {
                NSArray *arr= dict[@"roomList"];
                if ([arr containsObject:[NSNull null]]) {
                    if (completion) {
                        completion(YES,nil);
                    }
                } else {
                    if (completion) {
                        completion(YES,arr);
                    }
                }
            }
            
        } else {
            [self alert:[self getCode:response error:error]];
            if (completion) {
                completion(NO ,nil);
            }
        }
        
    }];
    [task  resume];
}
- (void)unpublish:(NSString *)roomId  completion:(void (^)(BOOL success))completion{
    NSString *host;
    if ([APPSERVER hasPrefix:@"http"]) {
        host = APPSERVER;
    } else {
        host = [@"https://" stringByAppendingString:APPSERVER];
    }
    NSURL* urlPost = [NSURL URLWithString:[NSString stringWithFormat:@"%@/unpublish",host]];
    NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:urlPost
                                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                        timeoutInterval:30.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *dic = @{@"roomId":roomId};
    NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
    request.HTTPBody = data;
    NSURLSessionTask *task = [self.defaultSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            if (completion) {
                completion(YES);
            }
        } else {
            if (completion) {
                completion(NO);
            }
            [self alert:[self getCode:response error:error]];
        }
    }];
    [task  resume];
}

-(void)fetchTokenWithUserId:(NSString *)userId username:(NSString *)username portraitUri:(NSString *)portraitUri completion:(RCFetchTokenCompletion)completion{
    if (!username) username = @"unknown";
    if (!portraitUri) portraitUri = @"http";
    NSString *appserver ;
    if ([APPSERVER hasPrefix:@"http"]) {
        appserver = APPSERVER;
    } else {
        appserver = [@"https://" stringByAppendingString:APPSERVER];
    }
    NSString *api = [NSString stringWithFormat:@"%@/user/get_token",appserver];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:api]];
    request.HTTPMethod = @"POST";
    
    [request setValue:RCIMAPPKey forHTTPHeaderField:@"App-Key"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSString *Nonce = [NSString stringWithFormat:@"%u",100000+arc4random()%100000];
    [request setValue:Nonce forHTTPHeaderField:@"Nonce"];
    
    NSString *Timestamp = [NSString stringWithFormat:@"%lu",(unsigned long)([NSDate date].timeIntervalSince1970 * 1000)];
    [request setValue:Timestamp forHTTPHeaderField:@"Timestamp"];
    
    NSString *Signature = [NSString stringWithFormat:@"%@%@",Nonce,Timestamp];
    [request setValue:Signature.sha1 forHTTPHeaderField:@"Signature"];
    NSDictionary *dic = @{@"id":userId};
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dic options:(NSJSONWritingPrettyPrinted) error:nil];
    
    NSURLSessionTask *task = [self.defaultSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSError *error = nil;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (result[@"result"]) {
                completion(YES,result[@"result"][@"token"]);
            }
            else{
                [self alert:[self getCode:response error:error]];
                completion(NO,nil);
            }
        }
        else{
            [self alert:[self getCode:response error:error]];
            completion(NO,nil);
        }
    }];
    
    [task resume];
    
}
- (void)getDemoVersionInfo:(void (^)(NSDictionary *respDict))resp
{
    NSString *host = APPSERVER;
    if (![host hasPrefix:@"http"]) {
        host = [@"https://" stringByAppendingString:APPSERVER];
    }
    NSURL* urlPost = [NSURL URLWithString:[host stringByAppendingString:@"/app/version"]];
    NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:urlPost
                                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                        timeoutInterval:30.0];
    request.HTTPMethod = @"GET";
    NSURLSessionTask *task = [self.defaultSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSInteger c = [dict[@"code"] integerValue];
            if (c == 200) {
                NSDictionary *resultDict = dict[@"result"];
                resp(resultDict);
            }
            else {
                resp(nil);
            }
        }
        else {
            resp(nil);
        }
    }];
    [task  resume];
}


- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
    }
}
- (void)alert:(NSInteger)code{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *str = [NSString stringWithFormat:@"http 层错误码:%@",@(code)];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误提示" message:str preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action];
        [self.chatVC presentViewController:alert animated:YES completion:nil];
    });
    
}
- (NSInteger)getCode:(NSURLResponse *)response error:(NSError *)error{
    NSInteger code = ((NSHTTPURLResponse *)response).statusCode ;
    return code > 0 ? code : error.code;
}
@end
