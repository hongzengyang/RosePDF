//
//  HZAlertTextFieldView.m
//  RosePDF
//
//  Created by THS on 2024/2/26.
//

#import "HZAlertTextFieldView.h"
#import "HZCommonHeader.h"

@implementation HZAlertTextFieldInput

@end

@interface HZAlertTextFieldView()<UITextFieldDelegate>

@property (nonatomic, strong) HZAlertTextFieldInput *inputModel;

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *errorTipLab;

@end

@implementation HZAlertTextFieldView
- (instancetype)initWithInput:(HZAlertTextFieldInput *)inputModel {
    if (self = [super init]) {
        self.inputModel = inputModel;
        [self configView];
    }
    return self;
}

- (void)configView {
    [self setFrame:[UIScreen mainScreen].bounds];
    self.backgroundColor = hz_getColorWithAlpha(@"000000", 0.5);
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake((self.width - 270)/2.0, (self.height - 138)/2.0 - 50, 270, 138)];
    contentView.layer.cornerRadius = 14;
    contentView.layer.masksToBounds = YES;
    [self addSubview:contentView];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [contentView addSubview:blurEffectView];
    [blurEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(contentView);
    }];
    
    UILabel *titleLab = [[UILabel alloc] init];
    [contentView addSubview:titleLab];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.font = [UIFont systemFontOfSize:14 weight:(UIFontWeightBold)];
    titleLab.textColor = hz_getColor(@"000000");
    titleLab.text = self.inputModel.title;
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(19);
        make.leading.equalTo(contentView).offset(16);
        make.trailing.equalTo(contentView).offset(-16);
    }];
    
    UITextField *textField = [[UITextField alloc] init];
    textField.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    [contentView addSubview:textField];
    [textField setSecureTextEntry:self.inputModel.encrypt];
    self.textField = textField;
    textField.delegate = self;
    textField.keyboardType = self.inputModel.keyboardType;
    [textField becomeFirstResponder];
    textField.textColor = hz_getColor(@"000000");
    textField.tintColor = [UIColor blackColor];
    if (self.inputModel.originText.length > 0) {
        textField.markedTextStyle = @{
            NSBackgroundColorAttributeName : hz_getColorWithAlpha(@"007AFF", 0.3)
        };
        [textField setMarkedText:self.inputModel.originText selectedRange:NSMakeRange(0, self.inputModel.originText.length)];
    }
    textField.font = [UIFont systemFontOfSize:14];
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(57);
        make.leading.equalTo(contentView).offset(20);
        make.trailing.equalTo(contentView).offset(-20);
        make.height.mas_equalTo(20);
    }];
    [textField addTarget:self action:@selector(onTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    textField.delegate = self;
    
    UIView *lineView = [[UIView alloc] init];
    [contentView addSubview:lineView];
    lineView.backgroundColor = hz_getColor(@"888888");
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(textField);
        make.top.equalTo(textField.mas_bottom);
        make.height.mas_equalTo(1.0);
    }];
    
    UILabel *errorTipLab = [[UILabel alloc] init];
    [contentView addSubview:errorTipLab];
    self.errorTipLab = errorTipLab;
    errorTipLab.textAlignment = NSTextAlignmentCenter;
    errorTipLab.font = [UIFont systemFontOfSize:12 weight:(UIFontWeightRegular)];
    errorTipLab.textColor = hz_getColor(@"FF3B30");
    [errorTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineView.mas_bottom);
        make.leading.equalTo(contentView).offset(16);
        make.trailing.equalTo(contentView).offset(-16);
        make.height.mas_equalTo(15);
    }];
    
    //3C3C43 36
    UIView *horSeparater = [[UIView alloc] init];
    [contentView addSubview:horSeparater];
    horSeparater.backgroundColor = hz_getColorWithAlpha(@"3C3C43", 0.36);
    [horSeparater mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(contentView);
        make.top.equalTo(errorTipLab.mas_bottom);
        make.height.mas_equalTo(0.33);
    }];
    
    UIView *verSeparater = [[UIView alloc] init];
    [contentView addSubview:verSeparater];
    verSeparater.backgroundColor = hz_getColorWithAlpha(@"3C3C43", 0.36);
    [verSeparater mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.bottom.equalTo(contentView);
        make.top.equalTo(errorTipLab.mas_bottom);
        make.width.mas_equalTo(0.33);
    }];
    
    UIButton *cancelBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [contentView addSubview:cancelBtn];
    [cancelBtn addTarget:self action:@selector(clickCancelButton) forControlEvents:(UIControlEventTouchUpInside)];
    [cancelBtn setTitle:self.inputModel.cancelText forState:(UIControlStateNormal)];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [cancelBtn setTitleColor:hz_getColor(@"007AFF") forState:(UIControlStateNormal)];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.equalTo(contentView);
        make.trailing.equalTo(verSeparater.mas_leading);
        make.top.equalTo(horSeparater.mas_bottom);
    }];
    
    UIButton *rightBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [contentView addSubview:rightBtn];
    [rightBtn addTarget:self action:@selector(clickRightButton) forControlEvents:(UIControlEventTouchUpInside)];
    [rightBtn setTitle:self.inputModel.rightText forState:(UIControlStateNormal)];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [rightBtn setTitleColor:hz_getColor(@"007AFF") forState:(UIControlStateNormal)];
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.bottom.equalTo(contentView);
        make.leading.equalTo(verSeparater.mas_trailing);
        make.top.equalTo(horSeparater.mas_bottom);
    }];
    
    contentView.transform = CGAffineTransformScale(contentView.transform, 1.1, 1.1);
    contentView.alpha = 0.0;
    [UIView animateWithDuration:0.25 animations:^{
        contentView.transform = CGAffineTransformIdentity;
        contentView.alpha = 1.0;
    }];
}

- (void)resignResponder {
    [self.textField resignFirstResponder];
}

- (NSString *)inputText {
    return self.textField.text;
}

- (void)setErrorMessage:(NSString *)errorMessage {
    _errorMessage = errorMessage;
    self.errorTipLab.text = errorMessage;
}

- (void)clickCancelButton {
    [self.textField resignFirstResponder];
    [self removeFromSuperview];
}

- (void)clickRightButton {
    if (self.inputText.length == 0) {
        return;
    }
    
    if (self.inputModel.rightBlock) {
        self.inputModel.rightBlock(self);
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
- (void)onTextFieldChanged:(UITextField *)textField {
    NSString *text = textField.text;
    if (!textField.markedTextRange.isEmpty) {
        textField.text = nil;
    }
    textField.markedTextStyle = @{
        NSBackgroundColorAttributeName : [UIColor clearColor]
    };
    [textField setMarkedText:@"" selectedRange:NSMakeRange(0, 0)];
    
    textField.text = text;
}


@end
