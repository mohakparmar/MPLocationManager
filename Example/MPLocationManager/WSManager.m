//
//  WSManager.m
//

#import "WSManager.h"

@implementation WSManager


+(void)getWSCallFor:(NSString *)str_ws_name params:(NSString *)param Completetion:(void (^) (NSDictionary *responseDictionary,NSError * error))completion{
    
    NSString *deviceRequestString = [NSString stringWithFormat:@"%@%@/%@", webURL, str_ws_name, param];
    if ([param isEqualToString:@""]) {
        deviceRequestString = [NSString stringWithFormat:@"%@%@", webURL, str_ws_name];
    }
    deviceRequestString = [deviceRequestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *JSONURL = [NSURL URLWithString:deviceRequestString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:JSONURL];
    NSURLSessionDataTask * dataTask = [
                                       [NSURLSession sharedSession]
                                       dataTaskWithRequest:request
                                       completionHandler:^(NSData * _Nullable data, NSURLResponse *response, NSError *error) {
                                           
                                           dispatch_async(dispatch_get_main_queue(),^{
                                               if(error != nil) {
                                                   completion(nil,error);
                                                   return;
                                               }
                                               NSError *myError;
                                               
                                               NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                               completion(responseDictionary,myError);

                                           });
                                       }
                                       ];
    [dataTask resume];
}

+(void)postWSCallFor:(NSString *)str_ws_name params:(NSMutableDictionary *)parameter Completetion:(void (^) (NSDictionary *responseDictionary,NSError * error))completion {

    NSString *str_url = [NSString stringWithFormat:@"%@%@", webURL, str_ws_name];
    str_url = [str_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *JSONURL = [NSURL URLWithString:str_url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:JSONURL];
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    NSURL* requestURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@",str_url]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    

    
    
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] isKindOfClass:[NSString class]]) {
        [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"Authorization"];
    }

    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *body = [NSMutableData data];
    for (NSString *param in parameter) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [parameter objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setURL:requestURL];

    NSURLSessionDataTask * dataTask = [
                                       [NSURLSession sharedSession]
                                       dataTaskWithRequest:request
                                       completionHandler:^(NSData * _Nullable data, NSURLResponse *response, NSError *error) {
                                           
                                           dispatch_async(dispatch_get_main_queue(),^{
                                               if(error != nil) {
                                                   completion(nil,error);
                                                   return;
                                               }
                                               NSError *myError;
                                               NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                               completion(responseDictionary,myError);
                                               
                                           });
                                       }
                                       ];
    [dataTask resume];

}

+(BOOL)checkInternetAvailibility
{
    Reachability *reach=[Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus=[reach currentReachabilityStatus];
    if (netStatus == NotReachable)
    {
        return false;
    }
    return true;
}


@end


