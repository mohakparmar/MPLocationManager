//
//  MPUtility.h
//  MPLocationManager
//
//  Created by Hemant Agrawal on 10/06/19.
//  Copyright © 2019 Mohak Parmar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPUtility : NSObject

+(UIAlertController *)showAlertWithTitleAndMessage:(NSString *)title message:(NSString *)msg;
+(void)setViewBorder:(UIView *)view colour:(NSString *)str_colour alpha:(int)alpha radius:(int)radius borderWidth:(int)borderWidth;
+(UIColor*)setColor:(NSString*)hex alpha:(CGFloat)alpha;
+(void)SetImageTintColor:(UIImageView*)imgView color:(NSString *)str_color;

@end

NS_ASSUME_NONNULL_END
