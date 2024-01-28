//
//  NSKeyedArchiver+HZCategory.h
//  HZFoundationKit
//
//  Created by THS on 2024/1/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSKeyedArchiver (HZCategory)

+ (void)hz_setObject:(id)data forKey:(NSString *)service;
+ (id)hz_objectForKey:(NSString *)service;
+ (void)hz_removeObjectForKey:(NSString *)service;

@end

NS_ASSUME_NONNULL_END
