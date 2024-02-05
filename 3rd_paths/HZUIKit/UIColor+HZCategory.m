//
//  UIColor+HZCategory.m
//  HZUIKit
//
//  Created by THS on 2024/2/5.
//

#import "UIColor+HZCategory.h"

@implementation UIColor (HZCategory)

+ (UIColor *)hz_getColor:(NSString *)hexColor {
    return [self hz_getColor:hexColor alpha:@"1.0"];
}

+ (UIColor *)hz_getColor:(NSString *)hexColor alpha:(NSString *)alpha
{
    if ([alpha isKindOfClass:[NSString class]] && [hexColor isKindOfClass:[NSString class]])
    {
        unsigned int red, green, blue;
        NSRange range;
        range.length =2;
        
        range.location =0;
        [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
        range.location =2;
        [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
        range.location =4;
        [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
        
        return [UIColor colorWithRed:(float)(red/255.0f)green:(float)(green/255.0f)blue:(float)(blue/255.0f)alpha:[alpha floatValue]];
    }
    
    return nil;
}


@end
