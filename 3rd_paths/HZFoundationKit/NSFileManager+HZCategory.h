//
//  NSFileManager+HZCategory.h
//  HZFoundationKit
//
//  Created by THS on 2024/1/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (HZCategory)

- (BOOL)hz_isFolder:(NSString *)folderPath;

///删除文件夹目录下的所有内容
- (void)hz_deleteContentsWithFolderPath:(NSString *)folderPath;

- (BOOL)hz_copyContentsFromFolderPath:(NSString *)fromPath toFolderPath:(NSString *)toPath;

- (NSString *)hz_toMorestTwoFloatMBSize:(long long)size;

@end

NS_ASSUME_NONNULL_END
