//
//  HZPDFMaker.h
//  RosePDF
//
//  Created by THS on 2024/2/21.
//

#import <Foundation/Foundation.h>

#import "HZProjectModel.h"

@interface HZPDFMaker : NSObject

+ (void)generatePDFWithProject:(HZProjectModel *)project completeBlock:(void(^)(NSString *pdfPath))completeBlock;

@end


