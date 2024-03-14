//
//  HZSearchViewController.m
//  RosePDF
//
//  Created by THS on 2024/3/11.
//

#import "HZSearchViewController.h"
#import "HZCommonHeader.h"

@interface HZSearchViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UIView *navBar;
@property (nonatomic, strong) UITextField *textField;

@end

@implementation HZSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configView];
}

- (void)configView {
    self.view.backgroundColor = hz_1_bgColor;
    
    [self.view addSubview:self.navBar];
}

- (void)clickCancelButton {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickClearButton {
    self.textField.text = @"";
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - Lazy
- (UIView *)navBar {
    if (!_navBar) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, hz_safeTop + 51)];
        _navBar = view;
        _navBar.backgroundColor = hz_getColorWithAlpha(@"FFFFFF", 0.75);
        
        UIButton *cancelBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_navBar addSubview:cancelBtn];
        [cancelBtn addTarget:self action:@selector(clickCancelButton) forControlEvents:(UIControlEventTouchUpInside)];
        [cancelBtn setTitle:NSLocalizedString(@"str_cancel", nil) forState:(UIControlStateNormal)];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [cancelBtn setTitleColor:hz_main_color forState:(UIControlStateNormal)];
        [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(view).offset(-16);
            make.centerY.equalTo(view).offset(hz_safeTop/2.0);
            make.height.mas_equalTo(20);
        }];
        
        UIView *containerView = [[UIView alloc] init];
        containerView.backgroundColor = hz_2_bgColor;
        containerView.layer.cornerRadius = 10;
        containerView.layer.masksToBounds = YES;
        [_navBar addSubview:containerView];
        [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(view).offset(16);
            make.centerY.equalTo(cancelBtn);
            make.height.mas_equalTo(36);
            make.trailing.equalTo(cancelBtn.mas_leading).offset(-11);
        }];
        {
            UIImageView *icon = [[UIImageView alloc] init];
            icon.image = [UIImage imageNamed:@"rose_search_icon"];
            [containerView addSubview:icon];
            [icon mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(containerView).offset(4);
                make.centerY.equalTo(containerView);
                make.width.height.mas_equalTo(28);
            }];
            
            UIButton *clearBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
            [containerView addSubview:clearBtn];
            [clearBtn setImage:[UIImage imageNamed:@"rose_setting_rename_close"] forState:(UIControlStateNormal)];
            [clearBtn addTarget:self action:@selector(clickClearButton) forControlEvents:(UIControlEventTouchUpInside)];
            [clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.equalTo(containerView).offset(-4);
                make.centerY.equalTo(containerView);
                make.width.height.mas_equalTo(28);
            }];
            
            UITextField *textField = [[UITextField alloc] init];
            textField.returnKeyType = UIReturnKeySearch;
            textField.delegate = self;
            [containerView addSubview:textField];
            textField.tintColor = hz_getColor(@"888888");
            textField.textColor = hz_getColor(@"888888");
            textField.font = [UIFont systemFontOfSize:16];
            [textField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(icon.mas_trailing).offset(4);
                make.top.bottom.equalTo(containerView);
                make.trailing.equalTo(clearBtn.mas_leading).offset(-4);
            }];
            self.textField = textField;
            [textField becomeFirstResponder];
        }
        
        UIView *separaterView = [[UIView alloc] init];
        [view addSubview:separaterView];
        separaterView.backgroundColor = hz_getColorWithAlpha(@"000000", 0.3);
        [separaterView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.leading.trailing.equalTo(view);
            make.height.mas_equalTo(0.33);
        }];
    }
    return _navBar;
}

@end
