//
//  HZCommonUtils.m
//  RosePDF
//
//  Created by THS on 2024/2/28.
//

#import "HZCommonUtils.h"

@implementation HZCommonUtils

+ (BOOL)validPassword:(NSString *)password {
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*_"];

    // 遍历密码中的每个字符，检查是否属于指定的字符集
    for (NSInteger i = 0; i < password.length; i++) {
        unichar character = [password characterAtIndex:i];
        if (![characterSet characterIsMember:character]) {
            // 密码包含非法字符，验证失败
            return NO;
        }
    }

    // 密码验证通过
    return YES;
}

@end
