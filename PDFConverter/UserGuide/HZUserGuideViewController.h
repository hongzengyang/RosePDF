//
//  HZUserGuideViewController.h
//  RosePDF
//
//  Created by THS on 2024/3/21.
//

#import "HZBaseViewController.h"


@interface HZUserGuideViewController : HZBaseViewController

@property (nonatomic, copy) void(^overBlock)(void);


+ (BOOL)checkDisplayed;

@end

