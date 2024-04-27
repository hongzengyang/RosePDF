//
//  HZIAPViewController.h
//  RosePDF
//
//  Created by THS on 2024/3/25.
//

#import "HZBaseViewController.h"

typedef NS_ENUM(NSUInteger, HZIAPSource) {
    HZIAPSource_guide,
    HZIAPSource_dailyOpen,
    HZIAPSource_home,
    HZIAPSource_convertLimit
};

@interface HZIAPViewController : HZBaseViewController

@property (nonatomic, assign) HZIAPSource source;

@property (nonatomic, copy) void(^clickCloseBlock)(void);
@property (nonatomic, copy) void(^successBlock)(void);


@end
