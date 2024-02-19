//
//  NSDate+HZCategory.m
//  HZFoundationKit
//
//  Created by THS on 2024/2/19.
//

#import "NSDate+HZCategory.h"

@implementation NSDate (HZCategory)

//2019-2-14 PM 3:06:55
+ (NSString *)hz_dateTimeStringWithTime:(NSTimeInterval)timeInterval {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd a hh:mm:ss"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    dateStr = [dateStr stringByReplacingOccurrencesOfString:@":" withString:@"."];
    return dateStr;
}

@end
