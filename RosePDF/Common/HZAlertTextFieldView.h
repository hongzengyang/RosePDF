//
//  HZAlertTextFieldView.h
//  RosePDF
//
//  Created by THS on 2024/2/26.
//

#import <UIKit/UIKit.h>

@class HZAlertTextFieldView;

typedef void(^HZAlertClickBlock)(HZAlertTextFieldView *alertView);

@interface HZAlertTextFieldInput : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *cancelText;
@property (nonatomic, copy) NSString *rightText;
@property (nonatomic, copy) HZAlertClickBlock cancelBlock;
@property (nonatomic, copy) HZAlertClickBlock rightBlock;
@property (nonatomic, assign) BOOL encrypt;
@property (nonatomic, assign) UIKeyboardType keyboardType;
@end

@interface HZAlertTextFieldView : UIView

@property (nonatomic, copy) NSString *errorMessage;
@property (nonatomic, copy) NSString *inputText;


- (instancetype)initWithInput:(HZAlertTextFieldInput *)inputModel;

- (void)resignResponder;

@end

