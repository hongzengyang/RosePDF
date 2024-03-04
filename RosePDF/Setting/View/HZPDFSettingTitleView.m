//
//  HZPDFSettingTitleView.m
//  RosePDF
//
//  Created by THS on 2024/2/20.
//

#import "HZPDFSettingTitleView.h"
#import "HZCommonHeader.h"

@interface HZPDFSettingTitleView()<UITextFieldDelegate>

@property (nonatomic, copy) NSString *inputText;


@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *rightBtn;

@end

@implementation HZPDFSettingTitleView

- (instancetype)initWithFrame:(CGRect)frame inputText:(NSString *)inputText {
    if (self = [super initWithFrame:frame]) {
        self.inputText = inputText;
        [self configView];
    }
    return self;
}

- (void)configView {
    UIButton *rightBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self addSubview:rightBtn];
    [rightBtn addTarget:self action:@selector(clickRightButton) forControlEvents:(UIControlEventTouchUpInside)];
    rightBtn.contentMode = UIViewContentModeCenter;
    [rightBtn setImage:[UIImage imageNamed:@"rose_setting_rename"] forState:(UIControlStateNormal)];
    [rightBtn setImage:[UIImage imageNamed:@"rose_setting_rename_close"] forState:(UIControlStateSelected)];
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self).offset(-16);
        make.width.height.mas_equalTo(28);
    }];
    self.rightBtn = rightBtn;
    
    UITextField *textField = [[UITextField alloc] init];
    textField.returnKeyType = UIReturnKeyDone;
    textField.delegate = self;
    [self addSubview:textField];
    textField.text = self.inputText;
    textField.textColor = [UIColor blackColor];
    textField.font = [UIFont systemFontOfSize:17];
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.trailing.equalTo(self);
        make.leading.equalTo(self).offset(16);
        make.trailing.equalTo(self.rightBtn.mas_leading).offset(-10);
    }];
    self.textField = textField;
    
    UIView *separater = [[UIView alloc] init];
    [self addSubview:separater];
    separater.backgroundColor = hz_2_bgColor;
    [separater mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.textField);
        make.bottom.trailing.equalTo(self);
        make.height.mas_equalTo(1.0);
    }];
}

- (NSString *)currentTitle {
    return self.textField.text;
}

- (void)clickRightButton {
    if (self.rightBtn.selected) {
        self.textField.text = @"";
    }else {
        [self.textField becomeFirstResponder];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.rightBtn.selected = YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.rightBtn.selected = NO;
    if (textField.text.length == 0) {
        textField.text = self.inputText;
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
