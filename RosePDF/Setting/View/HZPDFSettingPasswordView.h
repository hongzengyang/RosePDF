//
//  HZPDFSettingPasswordView.h
//  RosePDF
//
//  Created by THS on 2024/2/20.
//

#import <UIKit/UIKit.h>
#import "HZPDFSettingDataboard.h"

@interface HZPDFSettingPasswordView : UIView

@property (nonatomic, copy) void(^PasswordSwitchBlock)(void);

- (instancetype)initWithFrame:(CGRect)frame databoard:(HZPDFSettingDataboard *)databoard;

- (BOOL)openPswState;
- (NSString *)curPsw;

- (void)layoutAllViews;
@end

