//
//  HZPDFSettingSizeView.h
//  RosePDF
//
//  Created by THS on 2024/2/20.
//

#import <UIKit/UIKit.h>
#import "HZPDFSettingDataboard.h"


@interface HZPDFSettingSizeView : UIView
- (instancetype)initWithFrame:(CGRect)frame databoard:(HZPDFSettingDataboard *)databoard;

- (HZPDFSize)currentPdfSize;

+ (NSString *)orientationTitleWithOrientation:(HZPDFOrientation)orientation;

+ (NSString *)sizeTitleWithPdfSize:(HZPDFSize)size;
+ (NSString *)sizeDescWithPdfSize:(HZPDFSize)size;
@end
