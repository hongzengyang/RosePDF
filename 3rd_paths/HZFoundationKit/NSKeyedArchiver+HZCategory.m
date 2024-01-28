//
//  NSKeyedArchiver+HZCategory.m
//  HZFoundationKit
//
//  Created by THS on 2024/1/24.
//

#import "NSKeyedArchiver+HZCategory.h"
#import <Security/Security.h>

@implementation NSKeyedArchiver (HZCategory)

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            service, (id)kSecAttrService,
            service, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAlways,(id)kSecAttrAccessible,
            nil];
}
#pragma mark 写入
+ (void)hz_setObject:(id)data forKey:(NSString *)service
{
    if (data && service)
    {
        NSLog(@"==== HXKeychainAccessor 写入keychain ====");
        //Get search dictionary
        NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
        //Delete old item before add new item
        SecItemDelete((CFDictionaryRef)keychainQuery);
        //Add new object to search dictionary(Attention:the data format)
        [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
        //Add item to keychain with the search dictionary
        SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
    }
}
#pragma mark 读取
+ (id)hz_objectForKey:(NSString *)service
{
    id ret = nil;
    if (service)
    {
        NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
        //Configure the search setting
        //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
        [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
        [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
        
        CFDataRef keyData = NULL;
        if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr)
        {
            @try
            {
                ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
            }
            @catch (NSException *e)
            {
                NSLog(@"Unarchive of %@ failed: %@", service, e);
            }
            @finally
            {
            }
        }
        if (keyData)
            CFRelease(keyData);
    }

    return ret;
}
#pragma mark 删除

+ (void)hz_removeObjectForKey:(NSString *)service
{
    if (service)
    {
        NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
        SecItemDelete((CFDictionaryRef)keychainQuery);
    }
}


@end
