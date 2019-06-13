//
//  MPLocationObject.m
//  MPLocationManager
//
//  Copyright © 2019 Mohak Parmar. All rights reserved.
//

#import "MPLocationObject.h"

@implementation MPLocationObject
    
+(MPLocationObject *)initWithCLLocation:(CLLocation *)location Accuracy:(MPLocationAccuracy)accuracy UpdateTime:(MPLocationUpdateTime)updateTime {
    MPLocationObject *obj = [[MPLocationObject alloc] init];
    
    obj.MPLocation = location;
    obj.MPAccuracy = accuracy;
    obj.MPUpdateTime = updateTime;
    obj.MPTime = [NSDate date];
    
    return obj;
}

    
    
@end
