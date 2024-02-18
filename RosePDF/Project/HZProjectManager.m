//
//  HZProjectManager.m
//  RosePDF
//
//  Created by THS on 2024/2/6.
//

#import "HZProjectManager.h"
#import "HZProjectDefine.h"

@implementation HZProjectManager

+ (NSString *)ocrFolderPath {
    NSString *ocrPath = nil;
    NSString *libraryPath = HZLibraryPath;
    NSString *newFileFolderPath =  libraryPath;

    if (newFileFolderPath) {
        ocrPath = [NSString stringWithFormat:@"%@/%@",newFileFolderPath,OCR_FOLDER_NAME];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:newFileFolderPath]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:newFileFolderPath withIntermediateDirectories:NO attributes:nil error:&error];
            if (error)
            {
                NSLog(@"- create user path error:%@ -",error);
            }
        }
        if (![[NSFileManager defaultManager] fileExistsAtPath:ocrPath])
        {
            NSError *error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:ocrPath withIntermediateDirectories:NO attributes:nil error:&error];
            if (error)
            {
                NSLog(@"- create ocr path error:%@ -",error);
            }
        }
    }
    return ocrPath;
}

@end
