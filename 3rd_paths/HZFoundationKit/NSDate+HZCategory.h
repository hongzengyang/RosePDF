//
//  NSDate+HZCategory.h
//  HZFoundationKit
//
//  Created by THS on 2024/2/19.
//

#import <Foundation/Foundation.h>

@interface NSDate (HZCategory)

+ (NSString *)hz_dateTimeString1WithTime:(NSTimeInterval)timeInterval;

+ (NSString *)hz_dateTimeString2WithTime:(NSTimeInterval)timeInterval;

+ (BOOL)hz_checkFirstTimeOpenAppTodayWithKey:(NSString *)key;

@end

