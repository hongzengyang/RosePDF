//
//  HZPDFSettingSizeView.h
//  RosePDF
//
//  Created by THS on 2024/2/20.
//

#import <UIKit/UIKit.h>
#import "HZProjectModel.h"


@interface HZPDFSettingSizeView : UIView
- (instancetype)initWithFrame:(CGRect)frame project:(HZProjectModel *)project;

+ (NSString *)sizeTitleWithPdfSize:(HZPDFSize)size;
+ (NSString *)sizeDescWithPdfSize:(HZPDFSize)size;
@end
