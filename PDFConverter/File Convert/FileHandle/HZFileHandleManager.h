//
//  HZFileHandleManager.h
//  PDFConverter
//
//  Created by THS on 2024/4/28.
//

#import <Foundation/Foundation.h>
#import "HZProjectModel.h"

@interface HZFileHandleManager : NSObject

+ (HZFileHandleManager *)manager;

- (void)presentWordFileWithCompleteBlock:(void(^)(NSURL *wordUrl))completeBlock;

- (void)convertPdfUrl:(NSURL *)pdfUrl completeBlock:(void(^)(HZProjectModel *project))completeBlock;

- (void)safeFile:(NSURL *)url completeBlock:(void(^)(NSURL *wordUrl))completeBlock;

@end

