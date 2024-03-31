//
//  HZDetailPasswordView.m
//  RosePDF
//
//  Created by THS on 2024/2/26.
//

#import "HZDetailPasswordView.h"
#import "HZCommonHeader.h"

@interface HZDetailPasswordView()<UITextFieldDelegate>

@property (nonatomic, strong) HZProjectModel *project;

@property (nonatomic, strong) UILabel *errorTipLab;
@property (nonatomic, strong) UITextField *textField;

@end

@implementation HZDetailPasswordView
- (instancetype)initWithProject:(HZProjectModel *)project {
    if (self = [super init]) {
        self.project = project;
        [self configView];
    }
    return self;
}

- (void)configView {
    self.backgroundColor = hz_1_bgColor;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"rose_detail_lock"];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(88);
        make.top.equalTo(self).offset(108);
        make.centerX.equalTo(self);
    }];
    
    UILabel *errorTipLab = [[UILabel alloc] init];
    [self addSubview:errorTipLab];
    self.errorTipLab = errorTipLab;
    errorTipLab.textAlignment = NSTextAlignmentCenter;
    errorTipLab.font = [UIFont systemFontOfSize:12 weight:(UIFontWeightRegular)];
    errorTipLab.textColor = hz_getColor(@"FF3B30");
    [errorTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom);
        make.leading.trailing.equalTo(self);
        make.height.mas_equalTo(15);
    }];
    
    UIView *textContainerView = [[UIView alloc] init];
    [self addSubview:textContainerView];
    textContainerView.layer.cornerRadius = 16;
    textContainerView.layer.masksToBounds = YES;
    textContainerView.backgroundColor = hz_2_bgColor;
    [textContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(254);
        make.height.mas_equalTo(56);
        make.centerX.equalTo(self);
        make.top.equalTo(errorTipLab.mas_bottom).offset(5);
    }];
    
    UIButton *eyeBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [textContainerView addSubview:eyeBtn];
    [eyeBtn addTarget:self action:@selector(clickEyeButton:) forControlEvents:(UIControlEventTouchUpInside)];
    eyeBtn.contentMode = UIViewContentModeCenter;
    [eyeBtn setImage:[UIImage imageNamed:@"rose_setting_passwordEye_o"] forState:(UIControlStateNormal)];
    [eyeBtn setImage:[UIImage imageNamed:@"rose_setting_passwordEye"] forState:(UIControlStateSelected)];
    eyeBtn.selected = YES;
    [eyeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(textContainerView);
        make.trailing.equalTo(textContainerView).offset(-10);
        make.width.height.mas_equalTo(28);
    }];
    
    UITextField *textField = [[UITextField alloc] init];
    textField.returnKeyType = UIReturnKeyDone;
    textField.secureTextEntry = eyeBtn.selected;
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    textField.tintColor = [UIColor blackColor];
    textField.delegate = self;
    textField.font = [UIFont systemFontOfSize:17];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"str_enterpassword", nil) attributes:
    @{NSForegroundColorAttributeName:hz_getColor(@"B2B2B2"),
    NSFontAttributeName:textField.font}
    ];
    textField.attributedPlaceholder = attrString;
    
    [textContainerView addSubview:textField];
    textField.textColor = [UIColor blackColor];
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.top.bottom.equalTo(textContainerView);
        make.leading.equalTo(textContainerView).offset(12);
        make.trailing.equalTo(eyeBtn.mas_leading).offset(-10);
    }];
    self.textField = textField;
    
    UIButton *okBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self addSubview:okBtn];
    okBtn.layer.cornerRadius = 16;
    okBtn.layer.masksToBounds = YES;
    [okBtn addTarget:self action:@selector(clickOkButton) forControlEvents:(UIControlEventTouchUpInside)];
    [okBtn setTitle:NSLocalizedString(@"str_open", nil) forState:(UIControlStateNormal)];
    okBtn.titleLabel.font = [UIFont systemFontOfSize:17 weight:(UIFontWeightBold)];
    [okBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(254);
        make.height.mas_equalTo(56);
        make.centerX.equalTo(self);
        make.top.equalTo(textContainerView.mas_bottom).offset(16);
    }];
    
    [okBtn setNeedsLayout];
    [okBtn layoutIfNeeded];
    [okBtn hz_addGradientWithColors:@[hz_main_color,hz_getColor(@"83BAF2")] startPoint:CGPointMake(0, 0.5) endPoint:CGPointMake(1, 0.5)];
}

- (void)clickEyeButton:(UIButton *)button {
    button.selected = !button.selected;
    self.textField.secureTextEntry = button.selected;
}

- (void)clickOkButton {
    NSString *inputPsw = self.textField.text;
    if (![inputPsw isEqualToString:self.project.password]) {
        self.errorTipLab.text = NSLocalizedString(@"str_password_error", nil);
        return;
    }
    
    if (self.openSuccessBlock) {
        self.openSuccessBlock();
    }
}

- (void)configFirstResponder:(BOOL)flag {
    if (flag) {
        [self.textField becomeFirstResponder];
    }else {
        [self.textField resignFirstResponder];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    self.errorTipLab.text = nil;
    return YES;
}

@end
