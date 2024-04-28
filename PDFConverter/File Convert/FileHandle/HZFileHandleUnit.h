//
//  HZFileHandleUnit.h
//  PDFConverter
//
//  Created by THS on 2024/4/28.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface HZFileHandleUnit : NSObject

- (void)convertWord2ImagesWithPdfPath:(NSString *)pdfPath completeBlock:(void(^)(NSArray <UIImage *>*))completeBlock;

@end
