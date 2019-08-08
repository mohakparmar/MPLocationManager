# MPLocationManager

[![CI Status](https://img.shields.io/travis/mohakparmar/MPLocationManager.svg?style=flat)](https://travis-ci.org/mohakparmar/MPLocationManager)
[![Version](https://img.shields.io/cocoapods/v/MPLocationManager.svg?style=flat)](https://cocoapods.org/pods/MPLocationManager)
[![License](https://img.shields.io/cocoapods/l/MPLocationManager.svg?style=flat)](https://cocoapods.org/pods/MPLocationManager)
[![Platform](https://img.shields.io/cocoapods/p/MPLocationManager.svg?style=flat)](https://cocoapods.org/pods/MPLocationManager)

MPLocationManager makes it easy to get the device's current location and heading on iOS. It is an Objective-C library that also works great in Swift.

## What's wrong with CLLocationManager?

CLLocationManager requires you to manually detect and handle things like permissions, stale/inaccurate locations, errors, and more. CLLocationManager uses a more traditional delegate pattern instead of the modern block-based callback pattern. And while it works fine to track changes in the user's location over time (such as for turn-by-turn navigation), it is extremely cumbersome to correctly request a single location update (such as to determine the user's current city to get a weather forecast, or to autofill an address from the current location).

MPLocationManager makes it easy to request both the device's current location, either once or continuously, as well as the device's continuous heading. The API is extremely simple for both one-time location requests and recurring subscriptions to location updates. For one-time location requests, you can specify how accurate of a location you need, and how long you're willing to wait to get it. Significant location change monitoring is also supported. MPLocationManager is power efficient and conserves the device's battery by automatically determining and using the most efficient Core Location accuracy settings, and by automatically powering down location services (e.g. GPS or compass) as soon as they are no longer needed.

## Requirements

MPLocationManager requires iOS 9.0 or later.


# Installation
**Using CocoaPods**

1) Add the pod MPLocationManager to your Podfile.
2) pod 'MPLocationManager'
3) Run pod install from Terminal, then open your app's .xcworkspace file to launch Xcode.
4) import the MPLocationManager.h header.
5) With use_frameworks! in your Podfile

**For Swift**

1) Swift: import MPLocationManager
2) Objective-C: #import <MPLocationManager/MPLocationManager.h> (or with Modules enabled: @import MPLocationManager;)
3) Without use_frameworks! in your Podfile
4) Swift: Add #import "MPLocationManager.h" to your bridging header.
5) Objective-C: #import "MPLocationManager.h"

## Usage

Requesting Permission to Access Location Services

INTULocationManager automatically handles obtaining permission to access location services when you issue a location request and the user has not already granted your app permission to access location services.

**iOS 9 and above**

Starting with iOS 8, you must provide a description for how your app uses location services by setting a string for the key NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription in your app's Info.plist file. INTULocationManager determines which level of permissions to request based on which description key is present. You should only request the minimum permission level that your app requires, therefore it is recommended that you use the "When In Use" level unless you require more access. If you provide values for both description keys, the more permissive "Always" level is requested.

**iOS 11**

Starting with iOS 11, you must provide a description for how your app uses location services by setting a string for the key NSLocationAlwaysAndWhenInUseUsageDescription in your app's Info.plist file.

**App Trasport Security**

As SDK contain service calls you need to add app trasport security in your application. 

Read detail about trasport security : https://developers.google.com/admob/ios/app-transport-security

```
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    <key>NSAllowsArbitraryLoadsForMedia</key>
    <true/>
    <key>NSAllowsArbitraryLoadsInWebContent</key>
    <true/>
</dict>
```

## Methods

**Please set up delegate method and add your key for authorization and employee name with below methods**

```
[MPLocationManager sharedInstance].delegate = self;
[[MPLocationManager sharedInstance] setName:@"Name_Of_Employee"];
[[MPLocationManager sharedInstance] setToken:@"eyJzIjoxMj**************gdfgrgDrfd45345"];
```

**Start getting location using single line code :**

```
[[MPLocationManager sharedInstance] StartUpdatingLocation:self];
```

**Delegate method for getting location :**

```
-(void)SendLocation:(MPLocationObject *)location {
    NSLog(@"%@", location);
    _lblCurrentLocation.text = [NSString stringWithFormat:@"%@", location.MPLocation];
    
}
```

**You will get following kind of data in MPLocationObject :**

```
@property (nonatomic, strong) CLLocation *MPLocation;               // ClLocation Object
@property (nonatomic, assign) MPLocationAccuracy MPAccuracy;        // Current Accuracy
@property (nonatomic, assign) MPLocationUpdateTime MPUpdateTime;    // Current Location Update Time 
@property (nonatomic, retain) NSDate *MPTime;                       // Date and Time of Location  
@property (nonatomic, assign) CLLocationSpeed speed;                // Current Travelling Speed   
@property (nonatomic, assign) double battery;                       // Available Battery in percentage
```

## Various Settings 

**To Check Location Permission Status**

```
[[MPLocationManager sharedInstance] checkLocationPermissionStatus];
```

**To Set your desier accuracy to fetch location**

```
[[MPLocationManager sharedInstance] SetMaxAccuracy:kMPHorizontalAccuracyNear];
```

 > Available Accuracy type or you can also set your custome accuracy : 
 
 ```
static const CLLocationAccuracy kMPHorizontalAccuracyVeryFar=         5000.0;  // in meters
static const CLLocationAccuracy kMPHorizontalAccuracyFar =            1000.0;  // in meters
static const CLLocationAccuracy kMPHorizontalAccuracyModerate =       100.0;   // in meters
static const CLLocationAccuracy kMPHorizontalAccuracyNear =           15.0;    // in meters
static const CLLocationAccuracy kMPHorizontalAccuracyVeryNear=        5.0;     // in meters
```

**To Set timer in which you want location feed**

```
[[MPLocationManager sharedInstance] SetMaxUpdateTime:kMPUpdateTimeStale30Seconds];
```

 >Available timer type or you can also set your custome time (Default is 1 second) : 
 
 ```
static const NSTimeInterval kMPUpdateTimeStale10Minutes =             600.0;  // in seconds
static const NSTimeInterval kMPUpdateTimeStale5Minutes =              300.0;  // in seconds
static const NSTimeInterval kMPUpdateTimeStale1Minutes =              60.0;   // in seconds
static const NSTimeInterval kMPUpdateTimeStale30Seconds =             30.0;   // in seconds
static const NSTimeInterval kMPUpdateTimeStale5Seconds =              5.0;    // in seconds
```

**To Pause location update auto when no movement of user**
 
```
[[MPLocationManager sharedInstance] setPausesLocationUpdatesAutomatically:YES];
```

**To Pause location update auto when no movement of user**
 
```
[[MPLocationManager sharedInstance] setPausesLocationUpdatesAutomatically:YES];
```

**To set back ground location updates**

```
- (void)setBackgroundLocationUpdate:(BOOL) enabled;
```

**To set status bar indicator**

```
- (void)setShowsBackgroundLocationIndicator:(BOOL) shows;
```

**To get current battery life**

```
-(double)getCurrentBatteryLife;
```

**All errors are handle in below delegate method**

```
-(void)SendError:(MPLocationStatus)ErrorCode {
    switch (ErrorCode) {
        case MPLocationStatusTimedOut: {
            _lblCurrentLocation.text = @"Time Out";
            break;
        }
        case MPLocationStatusServicesNotDetermined: {
            _lblCurrentLocation.text = @"Awaiting for user permission.";
            break;
        }
        case MPLocationStatusServicesDenied: {
            _lblCurrentLocation.text = @"User denied the location permission.";
            break;
        }
        case MPLocationStatusServicesRestricted: {
            _lblCurrentLocation.text = @"Location services restricted by user.";
            break;
        }
        case MPLocationStatusServicesDisabled: {
            _lblCurrentLocation.text = @"Location services disable by user.";
            break;
        }
        case MPLocationStatusError: {
            _lblCurrentLocation.text = @"Gerring error while fetching location.";
            break;
        }
        case MPLocationStatusSuccess: {
            mapV.hidden = NO;
            _lblCurrentLocation.text = @"User has given the permission, waiting for next location.";
            break;
        }
        case MPLocationStatusTimerStart: {
            break;
        }
        case MPLocationStatusTimerStop: {
            lblCountDown.text = @"Enable Coundown";
            break;
        }
        case MPLocationStatusAddressFetched: {
            CLPlacemark *obj = [self.objLocation.MPPlaceMarks objectAtIndex:0];
            NSLog(@"%@", obj);
            break;
        }
        case MPLocationStatusErrorInAddressFetched: {
            lblCountDown.text = @"Error in fetching address. Please try again.";
            break;
        }
        case MPLocationStatusPause: {
            [btnStartUpdatingLocation setTitle:@"Start Updating Location" forState:YES];
            break;
        }
        default:
            break;
    }
}
```

## Example Project

Open the project included in the repository (requires Xcode 6 and iOS 8.0 or later). It contains a MPLocationManager scheme that will run a simple demo app. Please note that it can run in the iOS Simulator, but you need to go to the iOS Simulator's Debug > Location menu once running the app to simulate a location (the default is None).

## Author

mohakparmar, mohak@infoware.ws

## License

MPLocationManager is available under the MIT license. See the LICENSE file for more info.
