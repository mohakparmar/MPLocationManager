//
//  MPLocationDefines.h
//  MPLocationManager
//
//  Copyright © 2019 Mohak Parmar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

static const CLLocationAccuracy kMPHorizontalAccuracyVeryFar=         5000.0;  // in meters
static const CLLocationAccuracy kMPHorizontalAccuracyFar =            1000.0;  // in meters
static const CLLocationAccuracy kMPHorizontalAccuracyModerate =       100.0;   // in meters
static const CLLocationAccuracy kMPHorizontalAccuracyNear =           15.0;    // in meters
static const CLLocationAccuracy kMPHorizontalAccuracyVeryNear=        5.0;     // in meters

static const NSTimeInterval kMPUpdateTimeStale10Minutes =             600.0;  // in seconds
static const NSTimeInterval kMPUpdateTimeStale5Minutes =              300.0;  // in seconds
static const NSTimeInterval kMPUpdateTimeStale1Minutes =              60.0;   // in seconds
static const NSTimeInterval kMPUpdateTimeStale30Seconds =             30.0;   // in seconds
static const NSTimeInterval kMPUpdateTimeStale5Seconds =              5.0;    // in seconds

typedef NS_ENUM(NSUInteger, MPAuthorizationRequests) {
    MPAuthorizationRequestsTypeAuto,
    MPAuthorizationRequestsTypeAlways,
    MPAuthorizationRequestsTypeWhenInUse,
};

/** The possible states that location services can be in. */
typedef NS_ENUM(NSInteger, MPLocationServicesState) {
    /** User has already granted this app permissions to access location services, and they are enabled and ready for use by this app.
     Note: this state will be returned for both the "When In Use" and "Always" permission levels. */
    MPLocationServicesStateAvailable,
    /** User has not yet responded to the dialog that grants this app permission to access location services. */
    MPLocationServicesStateNotDetermined,
    /** User has explicitly denied this app permission to access location services. (The user can enable permissions again for this app from the system Settings app.) */
    MPLocationServicesStateDenied,
    /** User does not have ability to enable location services (e.g. parental controls, corporate policy, etc). */
    MPLocationServicesStateRestricted,
    /** User has turned off location services device-wide (for all apps) from the system Settings app. */
    MPLocationServicesStateDisabled
};

/** The possible states that heading services can be in. */
typedef NS_ENUM(NSInteger, MPHeadingServicesState) {
    /** Heading services are available on the device */
    MPHeadingServicesStateAvailable,
    /** Heading services are available on the device */
    MPHeadingServicesStateUnavailable,
};

/** Location Update Accuracy */
typedef NS_ENUM(NSInteger, MPLocationAccuracy) {
    // 'None' is not valid as a desired accuracy.
    /** Inaccurate (>5000 meters, and/or received >10 minutes ago). */
    MPLocationAccuracyNone = 0,
    
    // The below options are valid desired accuracies.
    /** 5000 meters or better. Lowest accuracy. */
    MPLocationAccuracyVeryFar,
    /** 1000 meters or better. */
    MPLocationAccuracyFar,
    /** 100 meters or better. */
    MPLocationAccuracyModerate,
    /** 15 meters or better. */
    MPLocationAccuracyNear,
    /** 5 meters or better. */
    MPLocationAccuracyVeryNear,
};


/** Location Update Time */
typedef NS_ENUM(NSInteger, MPLocationUpdateTime) {
    MPLocationUpdateTimeNone = 0,
    /** received within the last 10 minutes. */
    MPLocationUpdateTime10Minutes,
    /** received within the last 5 minutes. */
    MPLocationUpdateTime5Minutes,
    /** received within the last 1 minutes. */
    MPLocationUpdateTime1Minutes,
    /** received within the last 30 Seconds. */
    MPLocationUpdateTime30Seconds,
    /** received within the last 5 Seconds. */
    MPLocationUpdateTime5Seconds,
};


/** A status that will be passed in to the completion block of a location request. */
typedef NS_ENUM(NSInteger, MPLocationStatus) {
    // These statuses will accompany a valid location.
    /** Got a location and desired accuracy level was achieved successfully. */
    MPLocationStatusSuccess = 0,
    /** Got a location, but the desired accuracy level was not reached before timeout. (Not applicable to subscriptions.) */
    MPLocationStatusTimedOut,
    /** Fire when you stop timer for next location */
    MPLocationStatusTimerStop,
    /** Fire when you start timer for next location */
    MPLocationStatusTimerStart,
    /** Fire when address fetch successfully for given location */
    MPLocationStatusAddressFetched,
    /** Fire when error in address fetch for given location */
    MPLocationStatusErrorInAddressFetched,
    // These statuses indicate some sort of error, and will accompany a nil location.
    /** User has not yet responded to the dialog that grants this app permission to access location services. */
    MPLocationStatusServicesNotDetermined,
    /** User has explicitly denied this app permission to access location services. */
    MPLocationStatusServicesDenied,
    /** User does not have ability to enable location services (e.g. parental controls, corporate policy, etc). */
    MPLocationStatusServicesRestricted,
    /** User has turned off location services device-wide (for all apps) from the system Settings app. */
    MPLocationStatusServicesDisabled,
    /** An error occurred while using the system location services. */
    MPLocationStatusError,
    /** Pause location from location manager object. */
    MPLocationStatusPause,
    /** Name not available. */
    MPLocationStatusErrorDataValidation,
    /** Token Error. */
    MPLocationStatuszErrorToken,
    /** Permission Denied. */
    MPLocationStatusErrorPermissionDenied,
    /** Madnatory Error. */
    MPLocationStatusErrorDuplicateError,
    /** data not found Error. */
    MPLocationStatusErrorDataNotFound,
    /** Try catch Error. */
    MPLocationStatusErrorTryCatch,
    /** Bug Error. */
    MPLocationStatusErrorBug,
    /** General Error. */
    MPLocationStatusErrorGeneralError,
    /** Authentiation Error. */
    MPLocationStatusErrorAuthenticationError,
    /** Third Party Error. */
    MPLocationStatusErrorThirdPartyError,
    /** Third Start Stop Error. */
    MPLocationStatusTripAlreadyStarted,
    /** API Configuration Pending */
    MPLocationStatusPendingAPIConfiguration,
    /** API Configuration is wrong */
    MPLocationStatusWrongAPIConfiguration,
    /** Auth Code is wrong */
    MPLocationStatusWrongAuthCode,
    
    /** Token Status Code Success */
    MPLocationApiStatusSuccess,
    /** Token Status Code Invalid Login */
    MPLocationTokenApiStatusInvalidLogin,
    /** Token Status Code User Not Found */
    MPLocationTokenApiStatusUserNotFound,
    /** Token Status Code Invalid Auth Code */
    MPLocationTokenApiStatusInvalidAuthCode,
    /** Token Status Code Invalid Auth Code Format */
    MPLocationTokenApiStatusInvalidTokenCodeFormat,
    /** Token Status Code Unable to validate token expiry */
    MPLocationTokenApiStatusTokenValidationIssue,
    /** Token Status Code Token Expire */
    MPLocationTokenApiStatusTokenExpire,
    /** Token Status Code User Deactivate */
    MPLocationTokenApiStatusUserDeactivated,
    
    /** Redirect URL API Status Code Unauthorized request */
    MPLocationRedirectURLApiStatusRequestNotAuthorized,
    /** Redirect URL API Status Code Invalid Token */
    MPLocationRedirectURLApiStatusInvalidToken

};

