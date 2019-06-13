//
//  MPUtility.m
//  MPLocationManager
//
//  Created by Hemant Agrawal on 10/06/19.
//  Copyright © 2019 Mohak Parmar. All rights reserved.
//

#import "MPUtility.h"

@implementation MPUtility


/* Alert Controller common method */
+(UIAlertController *)showAlertWithTitleAndMessage:(NSString *)title message:(NSString *)msg
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        //Handle your yes please button action here
    }];
    [alert addAction:yesButton];
    return alert;
}

///* Ser View Border */
+(void)setViewBorder:(UIView *)view colour:(NSString *)str_colour alpha:(int)alpha radius:(int)radius borderWidth:(int)borderWidth
{
    view.layer.cornerRadius = radius;
    view.layer.masksToBounds = YES;
    view.layer.borderColor = [MPUtility setColor:str_colour alpha:alpha].CGColor;
    view.layer.borderWidth = borderWidth;
}

+(UIColor*)setColor:(NSString*)hex alpha:(CGFloat)alpha
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:alpha];
}


+(void)SetImageTintColor:(UIImageView*)imgView color:(NSString *)str_color {
    UIImage *image = [imgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    imgView.image = image;
    [imgView setTintColor:[MPUtility setColor:str_color alpha:1.0]];
}


@end
