//
//  NSError+HZCategory.m
//  HZFoundationKit
//
//  Created by THS on 2024/1/23.
//

#import "NSError+HZCategory.h"

@implementation NSError (HZCategory)

+ (NSError *)hz_errorWithMessage:(NSString *)message {
    [self hz_errorWithMessage:message code:-1];
}

+ (NSError *)hz_errorWithMessage:(NSString *)message code:(NSInteger)code {
    return [NSError errorWithDomain:@"error" code:code userInfo:@{NSLocalizedDescriptionKey:message, NSLocalizedFailureReasonErrorKey:message}];
}

@end
