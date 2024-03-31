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

#define pref_key_update_project  @"pref_key_update_project"
#define pref_key_delete_project  @"pref_key_delete_project"
#define pref_key_rename_project  @"pref_key_rename_project"

#define pref_key_project_psw_changed  @"pref_key_project_psw_changed"

typedef void(^CreateProjectBlock)(HZProjectModel *project);
typedef void(^CreatePagesBlock)(NSArray <HZPageModel *>*pages);
typedef void(^CreatePageBlock)(HZPageModel *page);

@interface HZProjectManager : NSObject

+ (NSString *)ocrFolderPath;
+ (NSString *)projectPathWithIdentifier:(NSString *)identifier;

+ (BOOL)isTmp:(NSString *)projectId;

+ (HZProjectModel *)createProjectWithFolderId:(NSString *)folderId isTmp:(BOOL)isTmp;
+ (void)duplicateTmpWithProject:(HZProjectModel *)project completeBlock:(CreateProjectBlock)completeBlock;
+ (void)addPagesWithImages:(NSArray <UIImage *>*)images inProject:(HZProjectModel *)project completeBlock:(CreatePagesBlock)completeBlock;
+ (void)deleteProject:(HZProjectModel *)project postNotification:(BOOL)postNotification completeBlock:(CreateProjectBlock)completeBlock;

+ (BOOL)renameProject:(HZProjectModel *)project name:(NSString *)name;

+ (void)migratePagesFromProject:(HZProjectModel *)fromProject toProject:(HZProjectModel *)toProject keepOrigin:(BOOL)keepOrigin completeBlock:(CreateProjectBlock)completeBlock;

+ (void)cleanTmpProjects;

+ (void)compressImage:(UIImage *)image toPath:(NSString *)toPath;

@end
