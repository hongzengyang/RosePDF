//
//  HZChangePasswordViewController.m
//  RosePDF
//
//  Created by THS on 2024/2/28.
//

#import "HZChangePasswordViewController.h"
#import "HZCommonHeader.h"
#import "HZBaseNavigationBar.h"
#import "HZProjectManager.h"
#import "HZPDFMaker.h"

@interface HZChangePasswordViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) HZProjectModel *project;

@property (nonatomic, strong) HZBaseNavigationBar *navBar;

@property (nonatomic, strong) UIButton *eyeBtn;
@property (nonatomic, strong) UITextField *textField;

@end

@implementation HZChangePasswordViewController

- (instancetype)initWithProject:(HZProjectModel *)project {
    if (self = [super init]) {
        self.project = project;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configView];
}

- (void)configView {
    [self.view addSubview:self.navBar];
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(self.view);
        make.height.mas_equalTo(hz_safeTop + navigationHeight);
    }];
    
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.layer.cornerRadius = 10;
    containerView.layer.masksToBounds = YES;
    [self.view addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(16);
        make.trailing.equalTo(self.view).offset(-16);
        make.top.equalTo(self.navBar.mas_bottom).offset(16);
        make.height.mas_equalTo(70);
    }];
    
    UIButton *rightBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [containerView addSubview:rightBtn];
    [rightBtn addTarget:self action:@selector(clickEyeButton) forControlEvents:(UIControlEventTouchUpInside)];
    rightBtn.contentMode = UIViewContentModeCenter;
    [rightBtn setImage:[UIImage imageNamed:@"rose_setting_passwordEye"] forState:(UIControlStateNormal)];
    [rightBtn setImage:[UIImage imageNamed:@"rose_setting_passwordEye"] forState:(UIControlStateSelected)];
    rightBtn.selected = YES;
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(containerView);
        make.trailing.equalTo(containerView).offset(-16);
        make.width.height.mas_equalTo(28);
    }];
    self.eyeBtn = rightBtn;
    
    UITextField *textField = [[UITextField alloc] init];
    textField.returnKeyType = UIReturnKeyDone;
    textField.secureTextEntry = rightBtn.selected;
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    textField.delegate = self;
    [containerView addSubview:textField];
    textField.textColor = [UIColor blackColor];
    textField.font = [UIFont systemFontOfSize:17];
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.eyeBtn);
        make.leading.equalTo(containerView).offset(16);
        make.trailing.equalTo(self.eyeBtn.mas_leading).offset(-10);
    }];
    self.textField = textField;
    [textField becomeFirstResponder];
}

- (void)clickEyeButton {
    self.eyeBtn.selected = !self.eyeBtn.selected;
    self.textField.secureTextEntry = self.eyeBtn.selected;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - lazy
- (HZBaseNavigationBar *)navBar {
    if (!_navBar) {
        _navBar = [[HZBaseNavigationBar alloc] init];
        [_navBar configBackImage:[UIImage imageNamed:@"rose_back"]];
        [_navBar configTitle:NSLocalizedString(@"str_changepassword", nil)];
        [_navBar configRightTitle:NSLocalizedString(@"str_save", nil)];
        
        @weakify(self);
        _navBar.clickBackBlock = ^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        };
        _navBar.clickRightBlock = ^{
            @strongify(self);
            NSString *input = self.textField.text;
            if (![HZCommonUtils validPassword:input]) {
                [SVProgressHUD showImage:nil status:NSLocalizedString(@"str_password_format_error", nil)];
                return;
            }
            
            self.project.openPassword = YES;
            self.project.password = input;
            [self.project updateInDataBase];
            
            [SVProgressHUD show];
            [HZPDFMaker generatePDFWithProject:self.project completeBlock:^(NSString *pdfPath) {
                @strongify(self);
                [SVProgressHUD dismiss];
                [[NSNotificationCenter defaultCenter] postNotificationName:pref_key_project_psw_changed object:self.project];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        };
    }
    return _navBar;
}

@end
