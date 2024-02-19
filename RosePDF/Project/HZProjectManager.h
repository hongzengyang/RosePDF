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

+ (void)createProjectWithFolderId:(NSString *)folderId isTmp:(BOOL)isTmp completeBlock:(CreateProjectBlock)completeBlock;
+ (void)createPagesWithImages:(NSArray <UIImage *>*)images inProject:(HZProjectModel *)project completeBlock:(CreatePagesBlock)completeBlock;

+ (void)deleteProject:(HZProjectModel *)project;

@end
