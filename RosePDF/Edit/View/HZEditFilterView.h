//
//  HZEditFilterView.h
//  RosePDF
//
//  Created by THS on 2024/2/29.
//

#import <UIKit/UIKit.h>
#import "HZEditDataboard.h"

@interface HZEditFilterView : UIView

@property (nonatomic, copy) void(^completeBlock)(void);
@property (nonatomic, copy) void(^clickFilterItemBlock)(HZFilterType filterType);
@property (nonatomic, copy) void(^slideBlock)(BOOL isFilter, HZFilterType filterType, HZAdjustType adjustType);


- (instancetype)initWithFrame:(CGRect)frame databoard:(HZEditDataboard *)databoard;
- (void)update;

@end

