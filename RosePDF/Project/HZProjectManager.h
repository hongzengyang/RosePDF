//
//  HZProjectManager.h
//  RosePDF
//
//  Created by THS on 2024/2/6.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HZProjectModel.h"
#import "HZPageModel.h"

typedef void(^CreateProjectBlock)(HZProjectModel *project);
typedef void(^CreatePagesBlock)(NSArray <HZPageModel *>*pages);
typedef void(^CreatePageBlock)(HZPageModel *page);

@interface HZProjectManager : NSObject

+ (NSString *)ocrFolderPath;
+ (NSString *)projectPathWithIdentifier:(NSString *)identifier;

+ (BOOL)isTmp:(NSString *)projectId;

+ (HZProjectModel *)createProjectWithFolderId:(NSString *)folderId isTmp:(BOOL)isTmp;
+ (void)addPagesWithImages:(NSArray <UIImage *>*)images inProject:(HZProjectModel *)project completeBlock:(CreatePagesBlock)completeBlock;
+ (void)deleteProject:(HZProjectModel *)project;

+ (void)migratePagesFromProject:(HZProjectModel *)fromProject toProject:(HZProjectModel *)toProject keepOrigin:(BOOL)keepOrigin completeBlock:(CreateProjectBlock)completeBlock;

+ (void)cleanTmpProjects;

@end
