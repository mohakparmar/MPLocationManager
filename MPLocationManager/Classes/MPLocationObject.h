//
//  MPLocationObject.h
//  MPLocationManager
//
//  Copyright © 2019 Mohak Parmar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPLocationDefines.h"

@interface MPLocationObject : NSObject

@property (nonatomic, strong) CLLocation *MPLocation;
@property (nonatomic, assign) MPLocationAccuracy MPAccuracy;
@property (nonatomic, assign) MPLocationUpdateTime MPUpdateTime;
@property (nonatomic, retain) NSDate *MPTime;
@property (nonatomic, retain) NSArray *MPPlaceMarks;

+(MPLocationObject *)initWithCLLocation:(CLLocation *)location Accuracy:(MPLocationAccuracy)accuracy UpdateTime:(MPLocationUpdateTime)updateTime;
    
@end

