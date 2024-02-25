//
//  HZPDFSettingPasswordView.h
//  RosePDF
//
//  Created by THS on 2024/2/20.
//

#import <UIKit/UIKit.h>
#import "HZProjectModel.h"

@interface HZPDFSettingPasswordView : UIView

@property (nonatomic, copy) void(^PasswordSwitchBlock)(void);


- (instancetype)initWithFrame:(CGRect)frame project:(HZProjectModel *)project;

- (void)layoutAllViews;
@end

