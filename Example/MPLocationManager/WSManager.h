//
//  WSManager.h
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface WSManager : NSObject

#define webURL @"http://204.141.208.30:82/api/"

#define WSTracking @"Tracking"


+(BOOL)checkInternetAvailibility;
+(void)getWSCallFor:(NSString *)str_ws_name params:(NSString *)param Completetion:(void (^) (NSDictionary *responseDictionary,NSError * error))completion;
+(void)postWSCallFor:(NSString *)str_ws_name params:(NSDictionary *)param Completetion:(void (^) (NSDictionary *responseDictionary,NSError * error))completion;

@end

