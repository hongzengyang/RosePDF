//
//  HZEditViewController.h
//  RosePDF
//
//  Created by THS on 2024/2/18.
//

#import "HZBaseViewController.h"
#import "HZProjectModel.h"


@interface HZEditInput : NSObject
@property (nonatomic, strong) HZProjectModel *project;        //tmp
@property (nonatomic, strong) HZProjectModel *originProject;
@end


@interface HZEditViewController : HZBaseViewController

- (instancetype)initWithInput:(HZEditInput *)input;

@end

