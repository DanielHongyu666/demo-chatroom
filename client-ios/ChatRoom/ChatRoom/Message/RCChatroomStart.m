
#import "RCChatroomStart.h"

@implementation RCChatroomStart

- (NSData *)encode {
  NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
  
      
        if (self.time) {
          [dataDict setObject:@(self.time) forKey:@"time"];
        } else {
           [dataDict setObject:@"" forKey:@"time"];
        }
      
  
      
        if (self.extra) {
          [dataDict setObject:self.extra forKey:@"extra"];
        } else {
           [dataDict setObject:@"" forKey:@"extra"];
        }
      
  


  NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:kNilOptions error:nil];
  return data;
}

- (void)decodeWithData:(NSData *)data {
  if (data == nil) {
    return;
  }
  NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
  NSDictionary *json = [[NSDictionary alloc] initWithDictionary:dictionary];
  if (json) {
    
      
        self.time = [[json objectForKey:@"time"] longValue];
      
      
      
    
      
        self.extra = [json objectForKey:@"extra"];
      
      
      
    
  }
}

+ (NSString *)getObjectName {
  return @"RC:Chatroom:Start";
}

- (NSArray<NSString *> *)getSearchableWords {
  return nil;
}

+ (RCMessagePersistent)persistentFlag {
  return 3;
}

@end

