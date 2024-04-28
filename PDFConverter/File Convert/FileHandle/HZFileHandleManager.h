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

- (void)convertPdfUrl:(NSURL *)pdfUrl completeBlock:(void(^)(HZProjectModel *project))completeBlock;

@end

