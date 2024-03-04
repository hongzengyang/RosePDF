//
//  HZPDFSettingQualityView.h
//  RosePDF
//
//  Created by THS on 2024/2/20.
//

#import <UIKit/UIKit.h>
#import "HZPDFSettingDataboard.h"


@interface HZPDFSettingQualityView : UIView
- (instancetype)initWithFrame:(CGRect)frame databoard:(HZPDFSettingDataboard *)databoard;

- (HZPDFQuality)currentQuality;

@end


