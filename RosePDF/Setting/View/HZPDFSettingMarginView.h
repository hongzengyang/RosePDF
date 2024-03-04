//
//  HZPDFSettingMarginView.h
//  RosePDF
//
//  Created by THS on 2024/2/20.
//

#import <UIKit/UIKit.h>
#import "HZPDFSettingDataboard.h"


@interface HZPDFSettingMarginView : UIView
- (instancetype)initWithFrame:(CGRect)frame databoard:(HZPDFSettingDataboard *)databoard;

- (HZPDFMargin)currentMargin;
@end


