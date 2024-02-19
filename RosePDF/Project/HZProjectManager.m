//
//  HZProjectManager.m
//  RosePDF
//
//  Created by THS on 2024/2/6.
//

#import "HZProjectManager.h"
#import "HZProjectDefine.h"
#import "HZCommonHeader.h"

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
            if (error) {
                NSLog(@"error:%@ -",error);
            }
        }
        if (![[NSFileManager defaultManager] fileExistsAtPath:ocrPath]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:ocrPath withIntermediateDirectories:NO attributes:nil error:&error];
            if (error) {
                NSLog(@"error:%@ -",error);
            }
        }
    }
    return ocrPath;
}

+ (NSString *)projectPathWithIdentifier:(NSString *)identifier {
    NSString *projectFolderPath = nil;
    NSString *ocrFolderPath = [HZProjectManager ocrFolderPath];
    if (ocrFolderPath.length > 0 && identifier.length > 0) {
        projectFolderPath = [ocrFolderPath stringByAppendingPathComponent:identifier];
    }
    return projectFolderPath;
}

+ (void)createProjectWithFolderId:(NSString *)folderId isTmp:(BOOL)isTmp completeBlock:(CreateProjectBlock)completeBlock {
    HZProjectModel *project;
    NSString *identifier = nil;
    if (isTmp) {
        identifier = [NSString stringWithFormat:@"%@_%@",Tmp_project_prefix, @([[NSDate date] timeIntervalSince1970])];
    }else {
        identifier = [NSUUID UUID].UUIDString;
    }
    NSString *projectPath = [self projectPathWithIdentifier:identifier];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if (isTmp) {
        [fileMgr removeItemAtPath:projectPath error:nil];
    }
    
    if (![fileMgr fileExistsAtPath:projectPath]) {
        [fileMgr createDirectoryAtPath:projectPath withIntermediateDirectories:NO attributes:nil error:nil];
        
        project = [[HZProjectModel alloc] init];
        project.identifier = identifier;
        project.folderId = (folderId.length > 0) ? folderId : Default_folderId;
    }
    if (completeBlock) {
        completeBlock(project);
    }
}

+ (void)createPagesWithImages:(NSArray <UIImage *>*)images inProject:(HZProjectModel *)project completeBlock:(CreatePagesBlock)completeBlock {
    NSMutableArray <HZPageModel *>*pages = [[NSMutableArray alloc] init];
    __block NSInteger callback = 0;
    [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [HZProjectManager createPageWithImage:obj inProject:project completeBlock:^(HZPageModel *page) {
            callback++;
            if (page) {
                [pages addObject:page];
            }
            if (callback == images.count) {
                project.pageModels = [pages copy];
                if (completeBlock) {
                    completeBlock(project.pageModels);
                }
            }
        }];
    }];
}

+ (void)createPageWithImage:(UIImage *)image inProject:(HZProjectModel *)project completeBlock:(CreatePageBlock)completeBlock {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *identifier = [NSUUID UUID].UUIDString;
        NSString *pageFolderPath = [HZPageModel folderPathWithPageId:identifier projectId:project.identifier];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSString *projectPath = [self projectPathWithIdentifier:project.identifier];
        if (![fileMgr fileExistsAtPath:projectPath]) {
            [fileMgr createDirectoryAtPath:projectPath withIntermediateDirectories:NO attributes:nil error:nil];
        }
        if (![fileMgr fileExistsAtPath:pageFolderPath]) {
            NSError *error = nil;
            [fileMgr createDirectoryAtPath:pageFolderPath withIntermediateDirectories:NO attributes:nil error:&error];
            if (error) {
                NSLog(@"createPageWithImage error:%@ -",error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completeBlock) {
                        completeBlock(nil);
                    }
                });
                return;
            }
        }
        
        HZPageModel *pageModel = [[HZPageModel alloc] init];
        pageModel.identifier = identifier;
        pageModel.projectId = project.identifier;
        
        UIImage *originalImage = [UIImage hz_fixOrientation:image];
        NSData *originData = UIImageJPEGRepresentation(originalImage, 0.5);
        [originData writeToFile:[pageModel originPath] atomically:YES];
        
        [pageModel refreshWithCompleteBlock:^{
            if (completeBlock) {
                completeBlock(pageModel);
            }
        }];
    });
}

+ (void)deleteProject:(HZProjectModel *)project {
    BOOL suc = NO;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *projectPath = [self projectPathWithIdentifier:project.identifier];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[NSFileManager defaultManager] removeItemAtPath:projectPath error:nil];
    });
    
    [project deleteInDataBase];
}

@end
