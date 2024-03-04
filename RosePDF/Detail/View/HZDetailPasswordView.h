//
//  HZDetailPasswordView.h
//  RosePDF
//
//  Created by THS on 2024/2/26.
//

#import <UIKit/UIKit.h>
#import "HZProjectModel.h"


@interface HZDetailPasswordView : UIView

@property (nonatomic, copy) void(^openSuccessBlock)(void);


- (instancetype)initWithProject:(HZProjectModel *)project;

- (void)configFirstResponder:(BOOL)flag;

@end


