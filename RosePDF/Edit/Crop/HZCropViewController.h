//
//  HZCropViewController.h
//  RosePDF
//
//  Created by THS on 2024/3/6.
//

#import "HZBaseViewController.h"
#import "HZPageModel.h"

@interface HZCropViewController : HZBaseViewController

@property (nonatomic, copy) void(^cropFinishBlock)(void);


- (instancetype)initWithPageModel:(HZPageModel *)pageModel;

@end
