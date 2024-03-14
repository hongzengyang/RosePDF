//
//  NSDate+HZCategory.m
//  HZFoundationKit
//
//  Created by THS on 2024/2/19.
//

#import "NSDate+HZCategory.h"

@implementation NSDate (HZCategory)

+ (NSString *)hz_dateTimeString1WithTime:(NSTimeInterval)timeInterval {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSLocale * localeStr = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    dateFormatter.locale= localeStr;
    
    NSString *dateStr = [dateFormatter stringFromDate:date];
    dateStr = [dateStr stringByReplacingOccurrencesOfString:@":" withString:@"."];
    return dateStr;
}

+ (NSString *)hz_dateTimeString2WithTime:(NSTimeInterval)timeInterval {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    
    NSLocale * localeStr = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    dateFormatter.locale= localeStr;
    
    NSString *dateStr = [dateFormatter stringFromDate:date];
    dateStr = [dateStr stringByReplacingOccurrencesOfString:@":" withString:@"."];
    return dateStr;
}

@end
