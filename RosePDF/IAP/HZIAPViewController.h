//
//  HZIAPViewController.h
//  RosePDF
//
//  Created by THS on 2024/3/25.
//

#import "HZBaseViewController.h"

@interface HZIAPViewController : HZBaseViewController

@property (nonatomic, copy) void(^clickCloseBlock)(void);
@property (nonatomic, copy) void(^successBlock)(void);


@end
