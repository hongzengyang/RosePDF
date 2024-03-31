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
    return dateStr;
}

+ (NSString *)hz_dateTimeString2WithTime:(NSTimeInterval)timeInterval {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    
    NSLocale * localeStr = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    dateFormatter.locale= localeStr;
    
    NSString *dateStr = [dateFormatter stringFromDate:date];
    return dateStr;
}

+ (BOOL)hz_checkFirstTimeOpenAppTodayWithKey:(NSString *)key {
    // 获取当前日期
    NSDate *currentDate = [NSDate date];
    // 创建一个日期格式化器
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    // 获取当前日期的字符串表示
    NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
    
    // 读取存储在NSUserDefaults中的日期
    NSString *lastOpenedDate = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    // 判断是否是当天第一次打开
    if (![currentDateString isEqualToString:lastOpenedDate]) {
        // 是当天第一次打开应用的操作
        // 将当前日期存储到NSUserDefaults中
        [[NSUserDefaults standardUserDefaults] setObject:currentDateString forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        return YES; // 返回YES表示当天第一次打开
    } else {
        // 不是当天第一次打开应用的操作
        return NO; // 返回NO表示不是当天第一次打开
    }
}

@end
