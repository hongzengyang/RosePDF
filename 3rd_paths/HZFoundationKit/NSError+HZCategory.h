//
//  NSError+HZCategory.h
//  HZFoundationKit
//
//  Created by THS on 2024/1/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError (HZCategory)

+ (NSError *)hz_errorWithMessage:(NSString *)message;
+ (NSError *)hz_errorWithMessage:(NSString *)message code:(NSInteger)code;

@end

NS_ASSUME_NONNULL_END
