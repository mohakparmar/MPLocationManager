#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MPLocationDefines.h"
#import "MPLocationManager.h"
#import "MPLocationObject.h"

FOUNDATION_EXPORT double MPLocationManagerVersionNumber;
FOUNDATION_EXPORT const unsigned char MPLocationManagerVersionString[];

