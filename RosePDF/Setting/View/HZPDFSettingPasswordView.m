//
//  HZPDFSettingPasswordView.m
//  RosePDF
//
//  Created by THS on 2024/2/20.
//

#import "HZPDFSettingPasswordView.h"
#import "HZCommonHeader.h"

@interface HZPDFSettingPasswordView()<UITextFieldDelegate>
@property (nonatomic, strong) HZProjectModel *project;

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UISwitch *stateSwitch;

@property (nonatomic, strong) UIView *bottomContainerView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *rightBtn;

@property (nonatomic, strong) UIView *separaterView;

@end

@implementation HZPDFSettingPasswordView

- (instancetype)initWithFrame:(CGRect)frame project:(HZProjectModel *)project {
    if (self = [super initWithFrame:frame]) {
        self.project = project;
        [self configView];
    }
    return self;
}

- (void)configView {
    UILabel *titleLab = [[UILabel alloc] init];
    [self addSubview:titleLab];
    titleLab.font = [UIFont systemFontOfSize:17];
    titleLab.textColor = [UIColor blackColor];
    titleLab.text = NSLocalizedString(@"str_setpassword", nil);
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(16);
        make.top.equalTo(self);
        make.height.mas_equalTo(70);
        make.width.mas_equalTo(250);
    }];
    self.titleLab = titleLab;
    
    UISwitch *sh = [[UISwitch alloc] init];
    [self addSubview:sh];
    [sh addTarget:self action:@selector(clickpdfEncryptSwitch:) forControlEvents:(UIControlEventTouchUpInside)];
    [sh mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-16);
        make.top.equalTo(self).offset(20);
    }];
    [sh setNeedsLayout];
    [sh layoutIfNeeded];
//    CGFloat scale = 30.0/sh.bounds.size.width;
//    sh.transform = CGAffineTransformMakeScale( scale, scale );
    sh.on = self.project.openPassword;
    sh.thumbTintColor = hz_getColor(@"FFFFFF");
    sh.onTintColor = hz_main_color;
    self.stateSwitch = sh;
    
    self.bottomContainerView = [[UIView alloc] init];
    [self addSubview:self.bottomContainerView];
    [self.bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.top.equalTo(self.titleLab.mas_bottom);
        make.height.mas_equalTo(28);
    }];
    
    UIButton *rightBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.bottomContainerView addSubview:rightBtn];
    [rightBtn addTarget:self action:@selector(clickRightButton) forControlEvents:(UIControlEventTouchUpInside)];
    rightBtn.contentMode = UIViewContentModeCenter;
    [rightBtn setImage:[UIImage imageNamed:@"rose_setting_passwordEye"] forState:(UIControlStateNormal)];
    [rightBtn setImage:[UIImage imageNamed:@"rose_setting_passwordEye"] forState:(UIControlStateSelected)];
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomContainerView);
        make.trailing.equalTo(self.bottomContainerView).offset(-16);
        make.width.height.mas_equalTo(28);
    }];
    self.rightBtn = rightBtn;
    
    UITextField *textField = [[UITextField alloc] init];
    textField.returnKeyType = UIReturnKeyDone;
    textField.secureTextEntry = rightBtn.selected;
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    textField.delegate = self;
    [self.bottomContainerView addSubview:textField];
    textField.text = self.project.password;
    textField.textColor = [UIColor blackColor];
    textField.font = [UIFont systemFontOfSize:17];
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.rightBtn);
        make.leading.equalTo(self.bottomContainerView).offset(16);
        make.trailing.equalTo(self.rightBtn.mas_leading).offset(-10);
    }];
    self.textField = textField;
    
    UIView *separater = [[UIView alloc] init];
    [self addSubview:separater];
    separater.backgroundColor = hz_2_bgColor;
    [separater mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(16);
        make.bottom.trailing.equalTo(self);
        make.height.mas_equalTo(1.0);
    }];
    self.separaterView = separater;
}

- (void)layoutAllViews {
    if (self.project.openPassword) {
        [self setHeight:115];
        self.bottomContainerView.hidden = NO;
        [self.bottomContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self);
            make.top.equalTo(self.titleLab.mas_bottom);
            make.height.mas_equalTo(28);
        }];
    }else {
        [self setHeight:67];
        self.bottomContainerView.hidden = YES;
        [self.bottomContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self);
            make.top.equalTo(self.titleLab.mas_bottom);
            make.height.mas_equalTo(0);
        }];
    }
}

- (void)clickRightButton {
    if (self.rightBtn.selected) {
        self.textField.text = @"";
    }else {
        [self.textField becomeFirstResponder];
    }
}

- (void)clickpdfEncryptSwitch:(UISwitch *)sh {
    if (!sh.isOn) {
        self.textField.text = @"";
    }
    
    self.project.openPassword = sh.isOn;
    
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
    
    if (self.PasswordSwitchBlock) {
        self.PasswordSwitchBlock();
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}
@end

