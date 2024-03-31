//
//  NSFileManager+HZCategory.m
//  HZFoundationKit
//
//  Created by THS on 2024/1/25.
//

#import "NSFileManager+HZCategory.h"

@implementation NSFileManager (HZCategory)

- (BOOL)hz_isFolder:(NSString *)folderPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL exists = [fileManager fileExistsAtPath:folderPath isDirectory:&isDirectory];

    if (exists && isDirectory) {
        return YES; // It's a directory
    } else {
        return NO;  // It's not a directory or doesn't exist
    }
}

- (void)hz_deleteContentsWithFolderPath:(NSString *)directoryPath {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:directoryPath error:&error];
    if (error) {
        NSLog(@"Error reading directory contents: %@", error);
        return;
    }
    
    for (NSString *item in contents) {
        NSString *itemPath = [directoryPath stringByAppendingPathComponent:item];
        
        BOOL isDirectory;
        if ([fileManager fileExistsAtPath:itemPath isDirectory:&isDirectory]) {
            if (isDirectory) {
                // Recursively delete subdirectories and their contents
                [self hz_deleteContentsWithFolderPath:itemPath];
                
                // Remove the directory itself
                if (![fileManager removeItemAtPath:itemPath error:&error]) {
                    NSLog(@"Error removing directory %@: %@", itemPath, error);
                }
            } else {
                // Remove files
                if (![fileManager removeItemAtPath:itemPath error:&error]) {
                    NSLog(@"Error removing file %@: %@", itemPath, error);
                }
            }
        }
    }
}

- (BOOL)hz_copyContentsFromFolderPath:(NSString *)fromPath toFolderPath:(NSString *)toPath {
    if (![self hz_isFolder:fromPath]) {
        return NO;
    }
    
    
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:toPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        return NO;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 获取源文件夹内的所有内容
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:fromPath error:nil];
    for (NSString *fileName in contents) {
        NSString *sourceFilePath = [fromPath stringByAppendingPathComponent:fileName];
        NSString *destinationFilePath = [toPath stringByAppendingPathComponent:fileName];
        // 使用文件管理器拷贝文件
        [fileManager copyItemAtPath:sourceFilePath toPath:destinationFilePath error:nil];
    }
    
    return YES;
}

- (NSString *)hz_toMorestTwoFloatMBSize:(long long)size {
    float floatSize = size/(1000*1000*1.0);
    if (fmodf(floatSize, 1)==0) {//如果有一位小数点
        return [NSString stringWithFormat:@"%.0f MB",floatSize];
    } else if (fmodf(floatSize*10, 1)==0) {//如果有两位小数点
        return [NSString stringWithFormat:@"%.1f MB",floatSize];
    }
    return [NSString stringWithFormat:@"%.2f MB",floatSize];
}

@end
