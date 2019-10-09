//
//  MPLocationManager.m
//  MPLocationManager
//
//  Copyright © 2019 Mohak Parmar. All rights reserved.
//

#import "MPLocationManager.h"

#ifndef MP_ENABLE_LOGGING
#   ifdef DEBUG
#       define MP_ENABLE_LOGGING 1
#   else
#       define MP_ENABLE_LOGGING 0
#   endif /* DEBUG */
#endif /* MP_ENABLE_LOGGING */

#if MP_ENABLE_LOGGING
#   define MPLMLog(...)          NSLog(@"MPLocationManager: %@", [NSString stringWithFormat:__VA_ARGS__]);
#else
#   define MPLMLog(...)
#endif /* MP_ENABLE_LOGGING */

@interface MPLocationManager () <CLLocationManagerDelegate>

/** The instance of CLLocationManager encapsulated by this class. */
@property (nonatomic, strong) CLLocationManager *locationManager;
/** The most recent current location, or nil if the current location is unknown, invalid, or stale. */
@property (nonatomic, strong) CLLocation *currentLocation;
/** Time Interval in which location update will required. */
@property (nonatomic, assign) NSTimeInterval timeInterval;
/** MPLocationObject To send data. */
@property (nonatomic, retain) MPLocationObject *objMPLocation;
/** MPLocationUpdateTime To send. */
@property (nonatomic, assign) MPLocationUpdateTime objMPLocationTime;
/** MPLocationAccuracy To send. */
@property (nonatomic, assign) MPLocationAccuracy objCurrentAccuracy;
/** Timer for location upates. */
@property (nonatomic, retain) NSTimer *timer;
/** Timer for location upates. */
@property (nonatomic, assign) BOOL mainForceSend;
/** Timer for counter. */
@property (nonatomic, assign) int nextLocationUpdateAvailable;
/** Timer for counter. */
@property (nonatomic, retain) NSTimer *timerForCounter;
/** Count down for next location update. */
@property (nonatomic, assign) BOOL mainCountDown;
/* Variable for name */
@property (nonatomic, retain) NSString *str_name;
/* Start Stop Flag */
@property (nonatomic, retain) NSString *str_start_stop_status;
/* API URL */
@property (nonatomic, retain) NSString *str_Url;
/* Update Location method Name */
@property (nonatomic, retain) NSString *str_update_location;
/* Check Location Location method Name */
@property (nonatomic, retain) NSString *str_check_location;

@end

@implementation MPLocationManager
@synthesize objMPLocation;

static id _sharedInstance;

/*  Create the singleton instance of this class.*/
+ (instancetype)sharedInstance
{
    static dispatch_once_t _onceToken;
    dispatch_once(&_onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

-(void)setAPIConfiguration:(NSString *)str_url TrackService:(NSString *)str_TrackService LocationStatusService:(NSString *)str_LocationStatusService {
    self.str_Url = str_url;
    self.str_update_location = str_TrackService;
    self.str_check_location = str_LocationStatusService;
}

- (instancetype)init {
    NSAssert(_sharedInstance == nil, @"Only one instance of MPLocationManager should be created. Use +[MPLocationManager sharedInstance] instead.");
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        self.preferredAuthorizationType = MPAuthorizationRequestsTypeAuto;
        
#ifdef __IPHONE_8_4
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_4
        /* iOS 9 requires setting allowsBackgroundLocationUpdates to YES in order to receive background location updates.
         We only set it to YES if the location background mode is enabled for this app, as the documentation suggests it is a
         fatal programmer error otherwise. */
        NSArray *backgroundModes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIBackgroundModes"];
        if ([backgroundModes containsObject:@"location"]) {
            if (@available(iOS 9, *)) {
                [_locationManager setAllowsBackgroundLocationUpdates:YES];
            }
        }
#endif /* __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_4 */
#endif /* __IPHONE_8_4 */
    }
    return self;
}

/** Set token */
- (void)setToken:(NSString *)str_token {
    [[NSUserDefaults standardUserDefaults] setValue:str_token forKey:@"token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/** Set name */
- (void)setName:(NSString *)str_name {
    self.str_name = str_name;
}


/** Requests permission to use location services on devices with iOS 8+. */
- (void)requestAuthorizationIfNeeded {
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    // As of iOS 8, apps must explicitly request location services permissions. MPLocationManager supports both levels, "Always" and "When In Use".
    // MPLocationManager determines which level of permissions to request based on which description key is present in your app's Info.plist
    // If you provide values for both description keys, the more permissive "Always" level is requested.
    
    double iOSVersion = floor(NSFoundationVersionNumber);
    BOOL isiOSVersion7to10 = iOSVersion > NSFoundationVersionNumber_iOS_7_1 && iOSVersion <= NSFoundationVersionNumber10_11_Max;
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        BOOL canRequestAlways = NO;
        BOOL canRequestWhenInUse = NO;
        if (isiOSVersion7to10) {
            canRequestAlways = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"] != nil;
            canRequestWhenInUse = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] != nil;
        } else {
            canRequestAlways = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysAndWhenInUseUsageDescription"] != nil;
            canRequestWhenInUse = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] != nil;
        }

        BOOL needRequestAlways = NO;
        BOOL needRequestWhenInUse = NO;
        switch (self.preferredAuthorizationType) {
            case MPAuthorizationRequestsTypeAuto:
                needRequestAlways = canRequestAlways;
                needRequestWhenInUse = canRequestWhenInUse;
                break;
            case MPAuthorizationRequestsTypeAlways:
                needRequestAlways = canRequestAlways;
                break;
            case MPAuthorizationRequestsTypeWhenInUse:
                needRequestWhenInUse = canRequestWhenInUse;
                break;
                
            default:
                break;
        }
        if (needRequestAlways) {
            [self.locationManager requestAlwaysAuthorization];
        } else if (needRequestWhenInUse) {
           // [self.locationManager requestWhenInUseAuthorization];
            [self.locationManager requestAlwaysAuthorization];
        } else {
            if (isiOSVersion7to10) {
                // At least one of the keys NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription MUST be present in the Info.plist file to use location services on iOS 8+.
                NSAssert(canRequestAlways || canRequestWhenInUse, @"To use location services in iOS 8+, your Info.plist must provide a value for either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription.");
            } else {
                // Key NSLocationAlwaysAndWhenInUseUsageDescription MUST be present in the Info.plist file to use location services on iOS 11+.
                NSAssert(canRequestAlways, @"To use location services in iOS 11+, your Info.plist must provide a value for NSLocationAlwaysAndWhenInUseUsageDescription.");
            }
        }
    }
#endif
}

#pragma mark - Setting and start location methods
-(void)StartUpdatingLocation:(id)delegate {
    self.delegate = delegate;
    [self checkLocationPermissionStatus];
    [[MPLocationManager sharedInstance] SetMaxAccuracy:kMPHorizontalAccuracyModerate];
    [self.locationManager startMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
    [self performSelector:@selector(checkLocationBeforeSend) withObject:nil afterDelay:5.0];
}

-(void)timerCounter {
    if (self.nextLocationUpdateAvailable == 0) {
        self.nextLocationUpdateAvailable = (int)self.timeInterval;
    } else {
        self.nextLocationUpdateAvailable--;
    }
}

- (void)SetMaxAccuracy:(MPLocationAccuracy)maxAccuracy {
    self.objCurrentAccuracy = maxAccuracy;
    switch (maxAccuracy) {
        case MPLocationAccuracyNone:
            break;
        case MPLocationAccuracyVeryFar:
        if (self.locationManager.desiredAccuracy != kCLLocationAccuracyThreeKilometers) {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
                MPLMLog(@"Changing location services accuracy level to: low (minimum).");
            }
            break;
        case MPLocationAccuracyFar:
            if (self.locationManager.desiredAccuracy != kCLLocationAccuracyKilometer) {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
                MPLMLog(@"Changing location services accuracy level to: medium low.");
            }
            break;
        case MPLocationAccuracyModerate:
            if (self.locationManager.desiredAccuracy != kCLLocationAccuracyHundredMeters) {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
                MPLMLog(@"Changing location services accuracy level to: medium.");
            }
            break;
        case MPLocationAccuracyNear:
            if (self.locationManager.desiredAccuracy != kCLLocationAccuracyNearestTenMeters) {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
                MPLMLog(@"Changing location services accuracy level to: medium high.");
            }
            break;
        case MPLocationAccuracyVeryNear:
            if (self.locationManager.desiredAccuracy != kCLLocationAccuracyBest) {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                MPLMLog(@"Changing location services accuracy level to: high (maximum).");
            }
            break;
        default:
            if (maxAccuracy != 0) {
                self.locationManager.desiredAccuracy = maxAccuracy;
            }
            break;
    }
}

- (void)SetMaxUpdateTime:(MPLocationUpdateTime)maxTime {
    switch (maxTime) {
        case MPLocationUpdateTimeNone:
            self.timeInterval = 1;
            break;
        case MPLocationUpdateTime1Minutes:
            self.timeInterval = 60;
            break;
        case MPLocationUpdateTime5Minutes:
            self.timeInterval = 300;
            break;
        case MPLocationUpdateTime5Seconds:
            self.timeInterval = 5;
            break;
        case MPLocationUpdateTime10Minutes:
            self.timeInterval = 600;
            break;
        case MPLocationUpdateTime30Seconds:
            self.timeInterval = 30;
            break;
        default: {
            if (maxTime != 0) {
                self.timeInterval = maxTime;
            } else {
                self.timeInterval = 1;
            }
            break;
        }
    }
    
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(checkLocationBeforeSend) userInfo:nil repeats:YES];
    if (_mainCountDown) {
        self.nextLocationUpdateAvailable = (int)self.timeInterval;
        [_timerForCounter invalidate];
        _timerForCounter = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerCounter) userInfo:nil repeats:YES];
    }
}

- (void)enableForceSend:(BOOL)forceSend {
    _mainForceSend = forceSend;
}

- (void)enableCoundown:(BOOL)enableCoundown {
    _mainCountDown = enableCoundown;
    if ([self.timer isValid] && _mainCountDown) {
        [self.timer invalidate];
        [_timerForCounter invalidate];
        _timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(checkLocationBeforeSend) userInfo:nil repeats:YES];
        _timerForCounter = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerCounter) userInfo:nil repeats:YES];
        [self.delegate SendError:MPLocationStatusTimerStart];
    } else {
        [self.delegate SendError:MPLocationStatusTimerStop];
        [_timerForCounter invalidate];
    }
}

/** To Stop Updating Location */
- (void)StopUpdatingLocation {
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"bglocation"] isEqualToString:@"1"]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"bglocation"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        objMPLocation = [MPLocationObject initWithCLLocation:self.currentLocation Accuracy:self.objCurrentAccuracy UpdateTime:self.objMPLocationTime battery:[self getCurrentBatteryLife]];
        [self WSForStopUpdateLocation:objMPLocation];
    }
    [_timer invalidate];
    [_timerForCounter invalidate];
    [self.delegate SendError:MPLocationStatusTimerStop];
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - Additions
/** To set back ground location updates */
- (void)setBackgroundLocationUpdate:(BOOL)enabled {
    if (@available(iOS 9, *)) {
        _locationManager.allowsBackgroundLocationUpdates = enabled;
        [[NSUserDefaults standardUserDefaults] setValue:enabled?@"1":@"0" forKey:@"bglocation"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if (!enabled) {
            [_timer invalidate];
            [_timerForCounter invalidate];
            [self.delegate SendError:MPLocationStatusTimerStop];
        }
    }
}

/** To set status bar indicator. */
- (void)setShowsBackgroundLocationIndicator:(BOOL) shows {
    if (@available(iOS 11, *)) {
        _locationManager.showsBackgroundLocationIndicator = shows;
    }
}

/** To pause and start location services */
- (void)setPausesLocationUpdatesAutomatically:(BOOL) pauses {
    _locationManager.pausesLocationUpdatesAutomatically = pauses;
}

-(double)getCurrentBatteryLife {
#if IOS_SIMULATOR
    MPLMLog(@"It's an iOS Simulator");
#else
    UIDevice *myDevice = [UIDevice currentDevice];
    [myDevice setBatteryMonitoringEnabled:YES];
    double batLeft = (double)[myDevice batteryLevel] * 100;
    return (double)batLeft;
#endif
}

#pragma mark CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *mostRecentLocation = [locations lastObject];
    self.currentLocation = mostRecentLocation;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    MPLMLog(@"Location services error: %@", [error localizedDescription]);
}

-(void)sendLocationObjectWithParameter {
    if (_currentLocation == nil) {
        return;
    }
    if (objMPLocation.MPLocation.coordinate.latitude == self.currentLocation.coordinate.latitude && objMPLocation.MPLocation.coordinate.longitude == self.currentLocation.coordinate.longitude) {
        return;
    }
    objMPLocation = [MPLocationObject initWithCLLocation:self.currentLocation Accuracy:self.objCurrentAccuracy UpdateTime:self.objMPLocationTime battery:[self getCurrentBatteryLife]];
    self.nextLocationUpdateAvailable = (int)self.timeInterval;
    if (![self checkValidToken]) {
        [self.delegate SendError:MPLocationStatusErrorDataValidation];
    } else if ([self.str_name isEqualToString:@""]) {
        [self.delegate SendError:MPLocationStatusErrorDataValidation];
    } else if (!self.str_Url.length || !self.str_update_location.length) {
        [self.delegate SendError:MPLocationStatusPendingAPIConfiguration];
    } else {
        if ([_str_start_stop_status isEqualToString:@"Start"] || [_str_start_stop_status isEqualToString:@"Tracking"]) {
            [self WSForUpdateLocation:objMPLocation];
        } else {
            [self WSForStopUpdateLocation:objMPLocation];
        }
    }
}

-(BOOL)checkValidToken {
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] isKindOfClass:[NSString class]]) {
        NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:@"token"];
        if (token.length) {
            return YES;
        }
    }
    return NO;
}

-(void)WSForUpdateLocation:(MPLocationObject *)objLocation {
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.str_Url, self.str_update_location]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.str_name forKey:@"EmployeeCode"];
    [dict setValue:[NSString stringWithFormat:@"%f", objLocation.MPLocation.coordinate.latitude] forKey:@"Latitude"];
    [dict setValue:[NSString stringWithFormat:@"%f", objLocation.MPLocation.coordinate.longitude] forKey:@"Longitude"];
    [dict setValue:[NSString stringWithFormat:@"%f", objLocation.speed] forKey:@"Speed"];
    [dict setValue:[NSString stringWithFormat:@"%f", objLocation.battery] forKey:@"Battery"];
    [dict setValue:[NSString stringWithFormat:@"%ld", (long)objLocation.MPAccuracy] forKey:@"Accuracy"];
    [dict setValue:_str_start_stop_status forKey:@"Event"];
    [dict setValue:@"IPHONE" forKey:@"Source"];

    NSLog(@"%@ %@", url.absoluteString, dict);
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *postLength=[NSString stringWithFormat:@"%lu", (unsigned long)[data length]];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"Authorization"];
    [urlRequest setHTTPBody:data];
    
    //Create task
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //Handle your response here
        if (data == nil) {
            [self.delegate SendError:MPLocationStatusWrongAPIConfiguration];
        } else {
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            if ([httpResponse statusCode] == 500) {
                NSString *str_error = [NSString stringWithFormat:@"%@", [responseDict valueForKey:@"ErrorNumber"]];
                [self sendErrorCode:str_error dict:responseDict];
                if ([str_error isEqualToString:@"50004"]) {
                    [self WSForStopUpdateLocation:objLocation];
                }
            } else {
                if ([httpResponse statusCode] == 401) {
                    [self.delegate SendError:MPLocationStatusErrorAuthenticationError];
                }
                [self.delegate sendServiceSuccessBlock:responseDict];
                self->objMPLocation.Status = self->_str_start_stop_status;
                [self.delegate SendLocation:self->objMPLocation];
            }
            self->_str_start_stop_status = @"Tracking";
        }
    }];
    [dataTask resume];
}

-(void)WSForStopUpdateLocation:(MPLocationObject *)objLocation {
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.str_Url, self.str_update_location]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.str_name forKey:@"EmployeeCode"];
    [dict setValue:[NSString stringWithFormat:@"%f", objLocation.MPLocation.coordinate.latitude] forKey:@"Latitude"];
    [dict setValue:[NSString stringWithFormat:@"%f", objLocation.MPLocation.coordinate.longitude] forKey:@"Longitude"];
    [dict setValue:[NSString stringWithFormat:@"%f", objLocation.speed] forKey:@"Speed"];
    [dict setValue:[NSString stringWithFormat:@"%f", objLocation.battery] forKey:@"Battery"];
    [dict setValue:[NSString stringWithFormat:@"%ld", (long)objLocation.MPAccuracy] forKey:@"Accuracy"];
    [dict setValue:@"Stop" forKey:@"Event"];
    [dict setValue:@"IPHONE" forKey:@"Source"];

    NSLog(@"%@ %@", url.absoluteString, dict);
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *postLength=[NSString stringWithFormat:@"%lu", (unsigned long)[data length]];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"Authorization"];
    [urlRequest setHTTPBody:data];
    
    //Create task
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //Handle your response here
        if (data == nil) {
            [self.delegate SendError:MPLocationStatusWrongAPIConfiguration];
        } else {
            self->_str_start_stop_status = @"Start";
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            if ([httpResponse statusCode] == 500) {
                NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                NSString *str_error = [NSString stringWithFormat:@"%@", [responseDict valueForKey:@"ErrorNumber"]];
                [self sendErrorCode:str_error dict:responseDict];
            } else {
                if ([httpResponse statusCode] == 401) {
                    [self.delegate SendError:MPLocationStatusErrorAuthenticationError];
                }
                NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                [self.delegate sendServiceSuccessBlock:responseDict];
                self->objMPLocation.Status = @"Stop";
                [self.delegate SendLocation:self->objMPLocation];
            }
        }
    }];
    [dataTask resume];
}

- (void)checkLocationUpdateStarted {
    
    if (![self checkValidToken]) {
        [self.delegate SendError:MPLocationStatusErrorDataValidation];
    } else if ([self.str_name isEqualToString:@""]) {
        [self.delegate SendError:MPLocationStatusErrorDataValidation];
    } else if (!self.str_Url.length || !self.str_check_location.length) {
        [self.delegate SendError:MPLocationStatusPendingAPIConfiguration];
    } else {
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.str_Url, self.str_check_location]];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        
        [urlRequest setHTTPMethod:@"GET"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"Authorization"];
        
        //Create task
        NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            //Handle your response here
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            if (data == nil) {
                [self.delegate SendError:MPLocationStatusWrongAPIConfiguration];
            } else {
                NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if ([httpResponse statusCode] == 500) {
                    NSString *str_error = [NSString stringWithFormat:@"%@", [responseDict valueForKey:@"ErrorNumber"]];
                    [self sendErrorCode:str_error dict:responseDict];
                } else {
                    NSString *str_code = [NSString stringWithFormat:@"%@", [responseDict valueForKey:@"Status"]];
                    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"bglocation"] isEqualToString:@"1"]) {
                        [[MPLocationManager sharedInstance] setBackgroundLocationUpdate:YES];
                        [[MPLocationManager sharedInstance] setPausesLocationUpdatesAutomatically:NO];
                        [self startPauseUpdate];
                    } else {
                        if ([str_code isEqualToString:@"1"]) {
                            [self startPauseUpdate];
                        } else {
                            self.str_start_stop_status = @"Start";
                        }
                    }
                }
                [self.delegate sendServiceSuccessBlock:responseDict];
            }
        }];
        [dataTask resume];
    }
}

-(void)startPauseUpdate {
    self.str_start_stop_status = @"Tracking";
    [self.delegate SendError:MPLocationStatusTripAlreadyStarted];
    [[MPLocationManager sharedInstance] SetMaxAccuracy:kMPHorizontalAccuracyModerate];
    [self.locationManager startMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
    [self performSelector:@selector(sendLocationObjectWithParameter) withObject:nil afterDelay:3.0];
}

- (void)checkLocationBeforeSend {
    if (![self checkValidToken]) {
        [self.delegate SendError:MPLocationStatusErrorDataValidation];
    } else if ([self.str_name isEqualToString:@""]) {
        [self.delegate SendError:MPLocationStatusErrorDataValidation];
    } else if (!self.str_Url.length || !self.str_check_location.length) {
        [self.delegate SendError:MPLocationStatusPendingAPIConfiguration];
    } else {
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.str_Url, self.str_check_location]];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        
        [urlRequest setHTTPMethod:@"GET"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"Authorization"];
        //Create task
        NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            //Handle your response here
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            if (data == nil) {
                [self.delegate SendError:MPLocationStatusWrongAPIConfiguration];
            } else {
                NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if ([httpResponse statusCode] == 500) {
                    NSString *str_error = [NSString stringWithFormat:@"%@", [responseDict valueForKey:@"ErrorNumber"]];
                    [self sendErrorCode:str_error dict:responseDict];
                } else {
                    NSString *str_code = [NSString stringWithFormat:@"%@", [responseDict valueForKey:@"Status"]];
                    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"bglocation"] isEqualToString:@"1"]) {
                        self.str_start_stop_status = @"Tracking";
                        [self sendLocationObjectWithParameter];
                    } else {
                        if ([str_code isEqualToString:@"1"]) {
                            self.str_start_stop_status = @"Tracking";
                            [self sendLocationObjectWithParameter];
                        } else {
                            self.str_start_stop_status = @"Start";
                            [self sendLocationObjectWithParameter];
                        }
                    }
                }
            }
        }];
        [dataTask resume];
    }
}

-(void)sendErrorCode:(NSString *)str_code dict:(NSDictionary *)dictionary {
    if ([str_code isEqualToString:@"50000"]) {
        [self.delegate SendError:MPLocationStatusErrorPermissionDenied];
    } else if ([str_code isEqualToString:@"50001"]) {
        NSString *str_error_code = [NSString stringWithFormat:@"%@", [dictionary valueForKey:@"ErrorState"]];
        if ([str_error_code isEqualToString:@"9"]) {
            [self.delegate SendError:MPLocationStatusErrorDataValidation];
        } else if ([str_error_code isEqualToString:@"10"]) {
            [self.delegate SendError:MPLocationTrackingApiStatusZeroLatLong];
        } else {
            [self.delegate SendError:MPLocationStatusErrorDataValidation];
        }
    } else if ([str_code isEqualToString:@"50002"]) {
        [self.delegate SendError:MPLocationStatusErrorDataValidation];
    } else if ([str_code isEqualToString:@"50003"]) {
        [self.delegate SendError:MPLocationStatusErrorDuplicateError];
    } else if ([str_code isEqualToString:@"50004"]) {
        NSString *str_error_code = [NSString stringWithFormat:@"%@", [dictionary valueForKey:@"ErrorState"]];
        if ([str_error_code isEqualToString:@"1"]) {
            [self.delegate SendError:MPLocationTrackingApiStatusTripAlreadyStarted];
        } else if ([str_error_code isEqualToString:@"2"]) {
            [self.delegate SendError:MPLocationTrackingApiStatusTripNotStarted];
        } else {
            [self.delegate SendError:MPLocationStatusErrorDataNotFound];
        }
    } else if ([str_code isEqualToString:@"50005"]) {
        [self.delegate SendError:MPLocationStatusErrorDataNotFound];
    } else if ([str_code isEqualToString:@"50006"]) {
        [self.delegate SendError:MPLocationStatusErrorTryCatch];
    } else if ([str_code isEqualToString:@"50007"]) {
        [self.delegate SendError:MPLocationStatusErrorBug];
    } else if ([str_code isEqualToString:@"50008"]) {
        [self.delegate SendError:MPLocationStatusErrorGeneralError];
    } else if ([str_code isEqualToString:@"50009"]) {
        [self.delegate SendError:MPLocationStatusErrorAuthenticationError];
    } else if ([str_code isEqualToString:@"50010"]) {
        [self.delegate SendError:MPLocationStatusErrorThirdPartyError];
    }
    [self.delegate sendServiceSuccessBlock:dictionary];
}


/**  Returns the most recent current location, or nil if the current location is unknown, invalid, or stale. */
- (CLLocation *)currentLocation {
    if (_currentLocation) {
        // Location isn't nil, so test to see if it is valid
        if (!CLLocationCoordinate2DIsValid(_currentLocation.coordinate) || (_currentLocation.coordinate.latitude == 0.0 && _currentLocation.coordinate.longitude == 0.0)) {
            // The current location is invalid; discard it and return nil
            _currentLocation = nil;
        }
    }
   // Location is either nil or valid at this point, return it
    return _currentLocation;
}

-(void)checkLocationPermissionStatus {
 //   NSLog(@"%d",[CLLocationManager authorizationStatus]);
    if ([CLLocationManager locationServicesEnabled]){
        NSLog(@"Location Services Enabled");
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusNotDetermined: {
                [self requestAuthorizationIfNeeded];
                [self.delegate SendError:MPLocationStatusServicesNotDetermined];
                break;
            }
            case kCLAuthorizationStatusRestricted: {
                [self.delegate SendError:MPLocationStatusServicesRestricted];
                break;
            }
            case kCLAuthorizationStatusDenied: {
                [self.delegate SendError:MPLocationStatusServicesDenied];
                break;
            }
            case kCLAuthorizationStatusAuthorizedAlways: {
                [self.delegate SendError:MPLocationStatusSuccess];
                break;
            }
            case kCLAuthorizationStatusAuthorizedWhenInUse: {
                [self.delegate SendError:MPLocationStatusSuccess];
                break;
            }
            default:
                break;
        }
    } else {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            [self.delegate SendError:MPLocationStatusServicesDenied];
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self checkLocationPermissionStatus];
}

-(void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    [self.delegate SendError:MPLocationStatusPause];
}

- (void)getNewTokenFromAuthCode:(NSString *)str_url str_auth_code:(NSString *)str_auth_code {
    
    if ([str_auth_code isEqualToString:@""]) {
        [self.delegate SendError:MPLocationStatusWrongAuthCode];
    } else if (!str_url.length) {
        [self.delegate SendError:MPLocationStatusPendingAPIConfiguration];
    } else {
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", str_url]];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        
        [urlRequest setHTTPMethod:@"GET"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setValue:str_auth_code forHTTPHeaderField:@"Authorization"];
        
        //Create task
        NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            //Handle your response here
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            if (data == nil) {
                [self.delegate SendError:MPLocationStatusWrongAPIConfiguration];
            } else {
                NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if ([httpResponse statusCode] == 500) {
                    NSString *str_error = [NSString stringWithFormat:@"%@", [responseDict valueForKey:@"ErrorNumber"]];
                    if ([str_error isEqualToString:@"50009"]) {
                        NSString *str_error_code = [NSString stringWithFormat:@"%@", [responseDict valueForKey:@"ErrorState"]];
                        if ([str_error_code isEqualToString:@"1"]) {
                            [self.delegate SendFetchTokenStatus:MPLocationTokenApiStatusInvalidLogin Token:@""];
                        } else if ([str_error_code isEqualToString:@"2"]) {
                            [self.delegate SendFetchTokenStatus:MPLocationTokenApiStatusUserNotFound Token:@""];
                        } else if ([str_error_code isEqualToString:@"3"]) {
                            [self.delegate SendFetchTokenStatus:MPLocationTokenApiStatusInvalidAuthCode Token:@""];
                        } else if ([str_error_code isEqualToString:@"4"]) {
                            [self.delegate SendFetchTokenStatus:MPLocationTokenApiStatusInvalidTokenCodeFormat Token:@""];
                        } else if ([str_error_code isEqualToString:@"5"]) {
                            [self.delegate SendFetchTokenStatus:MPLocationTokenApiStatusTokenValidationIssue Token:@""];
                        } else if ([str_error_code isEqualToString:@"6"]) {
                            [self.delegate SendFetchTokenStatus:MPLocationTokenApiStatusTokenExpire Token:@""];
                        } else if ([str_error_code isEqualToString:@"7"]) {
                            [self.delegate SendFetchTokenStatus:MPLocationTokenApiStatusUserDeactivated Token:@""];
                        }
                    } else {
                        [self sendErrorCode:str_error dict:responseDict];
                    }
                } else {
                    NSString *token = [NSString stringWithFormat:@"%@", [responseDict valueForKey:@"Data"]];
                    [self.delegate SendFetchTokenStatus:MPLocationApiStatusSuccess Token:token];
                    [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"token"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
        }];
        [dataTask resume];
    }
}

- (void)getRedirectUrlWithToken:(NSString *)str_url str_token:(NSString *)str_token {
    if ([str_token isEqualToString:@""]) {
        [self.delegate SendError:MPLocationStatuszErrorToken];
    } else if (!str_url.length) {
        [self.delegate SendError:MPLocationStatusPendingAPIConfiguration];
    } else {
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", str_url]];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        
        [urlRequest setHTTPMethod:@"GET"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setValue:str_token forHTTPHeaderField:@"Token"];
        
        //Create task
        NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            //Handle your response here
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            if (data == nil) {
                [self.delegate SendError:MPLocationStatusWrongAPIConfiguration];
            } else {
                NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if ([httpResponse statusCode] == 500) {
                    NSString *str_error = [NSString stringWithFormat:@"%@", [responseDict valueForKey:@"ErrorNumber"]];
                    if ([str_error isEqualToString:@"50009"]) {
                        NSString *str_error_code = [NSString stringWithFormat:@"%@", [responseDict valueForKey:@"ErrorState"]];
                        if ([str_error_code isEqualToString:@"8"]) {
                            [self.delegate SendRedirectUrlWithStatus:MPLocationRedirectURLApiStatusRequestNotAuthorized RedirectUrl:@""];
                        } else if ([str_error_code isEqualToString:@"4"]) {
                            [self.delegate SendRedirectUrlWithStatus:MPLocationRedirectURLApiStatusInvalidToken RedirectUrl:@""];
                        }
                    } else {
                        [self sendErrorCode:str_error dict:responseDict];
                    }
                } else {
                    NSString *url = [NSString stringWithFormat:@"%@", [responseDict valueForKey:@"Data"]];
                    [self.delegate SendRedirectUrlWithStatus:MPLocationApiStatusSuccess RedirectUrl:url];
                }
            }
        }];
        [dataTask resume];
    }
}

@end



