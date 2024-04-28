//
//  HZFileConvertView.h
//  PDFConverter
//
//  Created by THS on 2024/4/28.
//

#import <UIKit/UIKit.h>
#import "HZProjectModel.h"

@interface HZFileConvertView : UIView

- (void)convertWord:(NSURL *)wordUrl completeBlock:(void(^)(HZProjectModel *))completeBlock;

@end
