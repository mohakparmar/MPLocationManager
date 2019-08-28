//
//  MPLocationObject.m
//  MPLocationManager
//
//  Copyright © 2019 Mohak Parmar. All rights reserved.
//

#import "MPLocationObject.h"

@implementation MPLocationObject
    
+(MPLocationObject *)initWithCLLocation:(CLLocation *)location Accuracy:(MPLocationAccuracy)accuracy UpdateTime:(MPLocationUpdateTime)updateTime battery:(double)batteryLife {
    MPLocationObject *obj = [[MPLocationObject alloc] init];
    
    obj.MPLocation = location;
    obj.MPAccuracy = accuracy;
    obj.MPUpdateTime = updateTime;
    obj.MPTime = [NSDate date];
    obj.speed = location.speed;
    obj.battery = batteryLife;
    
    if (location.speed < 0) {
        obj.speed = 0;
    }

    if (accuracy < 0) {
        obj.MPAccuracy = 0;
    }

    if (batteryLife < 0) {
        obj.battery = 0;
    }
    
    return obj;
}

    
    
@end
