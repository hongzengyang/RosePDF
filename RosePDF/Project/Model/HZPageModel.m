//
//  HZPageModel.m
//  RosePDF
//
//  Created by THS on 2024/2/4.
//

#import "HZPageModel.h"
#import "HZCommonHeader.h"
#import "HZProjectManager.h"

@interface HZPageModel()

@end

@implementation HZPageModel
+ (HZPageModel *)readWithPageId:(NSString *)pageId projectId:(NSString *)projectId {
    HZPageModel *pageModel = nil;
    if (pageId.length > 0 && projectId.length > 0) {
        pageModel = [[HZPageModel alloc] init];
        pageModel.identifier = pageId;
        pageModel.projectId = projectId;
        [pageModel readFromDisk];
    }
    return pageModel;
}

- (void)readFromDisk {
    NSString *jsonStr = [NSString stringWithContentsOfFile:[self configPath] encoding:NSUTF8StringEncoding error:nil];
    HZPageModel *tmpModel = [HZPageModel yy_modelWithJSON:jsonStr];
    if (tmpModel) {
        //
        //
        //
        self.orientation = tmpModel.orientation;
    }
}

- (void)saveToDisk {
    NSString *jsonStr = [self yy_modelToJSONString];
    [jsonStr writeToFile:[self configPath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+ (NSString *)folderPathWithPageId:(NSString *)pageId projectId:(NSString *)projectId {
    NSString *pageFolderPath = nil;
    NSString *projectPath = [HZProjectManager projectPathWithIdentifier:projectId];
    if (projectPath.length > 0 && pageId.length > 0) {
        pageFolderPath = [projectPath stringByAppendingPathComponent:pageId];
    }
    return pageFolderPath;
}

- (NSString *)pageFolderPath {
    return [[self class] folderPathWithPageId:self.identifier projectId:self.projectId];
}

- (NSString *)originPath {
    return [[self pageFolderPath] stringByAppendingPathComponent:@"origin.jpg"];
}
- (NSString *)resultPath {
    return [[self pageFolderPath] stringByAppendingPathComponent:@"result.jpg"];
}

- (NSString *)configPath {
    return [[self pageFolderPath] stringByAppendingPathComponent:@"page.config"];
}

- (void)refreshWithCompleteBlock:(void (^)(void))completeBlock {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *originalImage = [UIImage imageWithContentsOfFile:[self originPath]];
        if (!originalImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock();
            });
            return;
        }
        
        //crop
        //rotate
        //filter
        
        UIImage *resultImage = originalImage;
        NSData *resultData = UIImageJPEGRepresentation(resultImage, 1.0);
        [resultData writeToFile:[self resultPath] atomically:YES];
        
        [self saveToDisk];
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock();
        });
    });
}

@end
