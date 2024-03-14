//
//  HZHomeProjectItemView.m
//  RosePDF
//
//  Created by THS on 2024/2/28.
//

#import "HZHomeProjectItemView.h"
#import "HZCommonHeader.h"
#import "HZAlertTextFieldView.h"
#import "HZProjectManager.h"
#import "HZEditViewController.h"
#import "HZPDFSettingViewController.h"
#import "HZChangePasswordViewController.h"
#import <HZUIKit/HZActionSheet.h>
#import "HZPDFMaker.h"
#import "HZShareManager.h"

@interface HZHomeProjectItemView()

@property (nonatomic, strong) HZProjectModel *project;

@property (nonatomic, strong) UIView *containerView;

@end

@implementation HZHomeProjectItemView
- (instancetype)initWithProject:(HZProjectModel *)project {
    if (self = [super init]) {
        self.project = project;
        [self configView];
    }
    return self;
}

- (void)configView {
    UIViewController *viewController = [UIView hz_viewController];
    
    [self setFrame:viewController.view.bounds];
    self.backgroundColor = hz_getColorWithAlpha(@"000000", 0.5);
    
    BOOL containPsw = NO;
    if (self.project.openPassword && self.project.password.length > 0) {
        containPsw = YES;
    }
    
    CGFloat itemHeight = 50;
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height, self.width, 0)];
    containerView.backgroundColor = hz_getColor(@"E8E8E8");
    self.containerView = containerView;
    [self addSubview:containerView];
    
    UIView *rangView = [[UIView alloc] initWithFrame:CGRectMake((self.width - 44)/2.0, 20, 44, 5)];
    rangView.backgroundColor = hz_getColor(@"B2B2B2");
    rangView.layer.cornerRadius = 2;
    [containerView addSubview:rangView];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(16, rangView.bottom + 25, self.width - 32, itemHeight)];
    {
        titleView.layer.cornerRadius = 10;
        titleView.layer.masksToBounds = YES;
        [containerView addSubview:titleView];
        titleView.backgroundColor = [UIColor whiteColor];
        
        UILabel *leftLab = [[UILabel alloc] init];
        [titleView addSubview:leftLab];
        leftLab.text = NSLocalizedString(@"str_rename", nil);
        leftLab.font = [UIFont systemFontOfSize:17];
        leftLab.textColor = hz_1_textColor;
        [leftLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(titleView).offset(16);
            make.centerY.equalTo(titleView);
        }];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeCenter;
        [titleView addSubview:imageView];
        imageView.image = [UIImage imageNamed:@"rose_detail_rename"];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(titleView).offset(-16);
            make.centerY.equalTo(titleView);
            make.width.height.mas_equalTo(28);
        }];
        
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [button setFrame:titleView.bounds];
        button.backgroundColor = [UIColor clearColor];
        [titleView addSubview:button];
        [button addTarget:self action:@selector(clickTitle) forControlEvents:(UIControlEventTouchUpInside)];
    }
    
    UIView *pswView = [[UIView alloc] initWithFrame:CGRectMake(titleView.left, titleView.bottom+10, titleView.width, containPsw ? itemHeight * 2 : itemHeight)];
    pswView.layer.cornerRadius = 10;
    pswView.layer.masksToBounds = YES;
    [containerView addSubview:pswView];
    pswView.backgroundColor = [UIColor whiteColor];
    if (!containPsw) {
        UIView *addPswView = [[UIView alloc] initWithFrame:pswView.bounds];
        addPswView.layer.cornerRadius = 10;
        addPswView.layer.masksToBounds = YES;
        [pswView addSubview:addPswView];
        addPswView.backgroundColor = [UIColor whiteColor];
        
        UILabel *leftLab = [[UILabel alloc] init];
        [addPswView addSubview:leftLab];
        leftLab.text = NSLocalizedString(@"str_setpassword", nil);
        leftLab.font = [UIFont systemFontOfSize:17];
        leftLab.textColor = hz_1_textColor;
        [leftLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(addPswView).offset(16);
            make.centerY.equalTo(addPswView);
        }];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeCenter;
        [addPswView addSubview:imageView];
        imageView.image = [UIImage imageNamed:@"rose_add_psw"];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(addPswView).offset(-16);
            make.centerY.equalTo(addPswView);
            make.width.height.mas_equalTo(28);
        }];
        
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [button setFrame:addPswView.bounds];
        button.backgroundColor = [UIColor clearColor];
        [addPswView addSubview:button];
        [button addTarget:self action:@selector(clickAddPsw) forControlEvents:(UIControlEventTouchUpInside)];
    }else {
        {
            UIView *changePswView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pswView.width, itemHeight)];
            [pswView addSubview:changePswView];
            changePswView.backgroundColor = [UIColor whiteColor];
            
            UILabel *leftLab = [[UILabel alloc] init];
            [changePswView addSubview:leftLab];
            leftLab.text = NSLocalizedString(@"str_changepassword", nil);
            leftLab.font = [UIFont systemFontOfSize:17];
            leftLab.textColor = hz_1_textColor;
            [leftLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(changePswView).offset(16);
                make.centerY.equalTo(changePswView);
            }];
            
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.contentMode = UIViewContentModeCenter;
            [changePswView addSubview:imageView];
            imageView.image = [UIImage imageNamed:@"rose_change_psw"];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.equalTo(changePswView).offset(-16);
                make.centerY.equalTo(changePswView);
                make.width.height.mas_equalTo(28);
            }];
            
            UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
            [button setFrame:changePswView.bounds];
            button.backgroundColor = [UIColor clearColor];
            [changePswView addSubview:button];
            [button addTarget:self action:@selector(clickChangePsw) forControlEvents:(UIControlEventTouchUpInside)];
            
            UIView *separater = [[UIView alloc] init];
            separater.backgroundColor = hz_1_bgColor;
            [changePswView addSubview:separater];
            [separater mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(leftLab);
                make.trailing.bottom.equalTo(changePswView);
                make.height.mas_equalTo(1);
            }];
        }
        {
            UIView *removePswView = [[UIView alloc] initWithFrame:CGRectMake(0, itemHeight, pswView.width, itemHeight)];
            [pswView addSubview:removePswView];
            removePswView.backgroundColor = [UIColor whiteColor];
            
            UILabel *leftLab = [[UILabel alloc] init];
            [removePswView addSubview:leftLab];
            leftLab.text = NSLocalizedString(@"str_removepassword", nil);
            leftLab.font = [UIFont systemFontOfSize:17];
            leftLab.textColor = hz_1_textColor;
            [leftLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(removePswView).offset(16);
                make.centerY.equalTo(removePswView);
            }];
            
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.contentMode = UIViewContentModeCenter;
            [removePswView addSubview:imageView];
            imageView.image = [UIImage imageNamed:@"rose_remove_psw"];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.equalTo(removePswView).offset(-16);
                make.centerY.equalTo(removePswView);
                make.width.height.mas_equalTo(28);
            }];
            
            UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
            [button setFrame:removePswView.bounds];
            button.backgroundColor = [UIColor clearColor];
            [removePswView addSubview:button];
            [button addTarget:self action:@selector(clickRemovePsw) forControlEvents:(UIControlEventTouchUpInside)];
        }
    }
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(titleView.left, pswView.bottom+10, titleView.width, itemHeight * 4)];
    bottomView.layer.cornerRadius = 10;
    bottomView.layer.masksToBounds = YES;
    [containerView addSubview:bottomView];
    bottomView.backgroundColor = [UIColor whiteColor];
    {
        UIView *editView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bottomView.width, itemHeight)];
        [bottomView addSubview:editView];
        editView.backgroundColor = [UIColor whiteColor];
        
        UILabel *leftLab = [[UILabel alloc] init];
        [editView addSubview:leftLab];
        leftLab.text = NSLocalizedString(@"str_edit", nil);
        leftLab.font = [UIFont systemFontOfSize:17];
        leftLab.textColor = hz_1_textColor;
        [leftLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(editView).offset(16);
            make.centerY.equalTo(editView);
        }];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeCenter;
        [editView addSubview:imageView];
        imageView.image = [UIImage imageNamed:@"rose_detail_edit"];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(editView).offset(-16);
            make.centerY.equalTo(editView);
            make.width.height.mas_equalTo(28);
        }];
        
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [button setFrame:editView.bounds];
        button.backgroundColor = [UIColor clearColor];
        [editView addSubview:button];
        [button addTarget:self action:@selector(clickEdit) forControlEvents:(UIControlEventTouchUpInside)];
        
        UIView *separater = [[UIView alloc] init];
        separater.backgroundColor = hz_1_bgColor;
        [editView addSubview:separater];
        [separater mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(leftLab);
            make.trailing.bottom.equalTo(editView);
            make.height.mas_equalTo(1);
        }];
    }
    {
        UIView *settingView = [[UIView alloc] initWithFrame:CGRectMake(0, itemHeight, bottomView.width, itemHeight)];
        [bottomView addSubview:settingView];
        settingView.backgroundColor = [UIColor whiteColor];
        
        UILabel *leftLab = [[UILabel alloc] init];
        [settingView addSubview:leftLab];
        leftLab.text = NSLocalizedString(@"str_settings", nil);
        leftLab.font = [UIFont systemFontOfSize:17];
        leftLab.textColor = hz_1_textColor;
        [leftLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(settingView).offset(16);
            make.centerY.equalTo(settingView);
        }];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeCenter;
        [settingView addSubview:imageView];
        imageView.image = [UIImage imageNamed:@"rose_item_setting"];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(settingView).offset(-16);
            make.centerY.equalTo(settingView);
            make.width.height.mas_equalTo(28);
        }];
        
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [button setFrame:settingView.bounds];
        button.backgroundColor = [UIColor clearColor];
        [settingView addSubview:button];
        [button addTarget:self action:@selector(clickSetting) forControlEvents:(UIControlEventTouchUpInside)];
        
        UIView *separater = [[UIView alloc] init];
        separater.backgroundColor = hz_1_bgColor;
        [settingView addSubview:separater];
        [separater mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(leftLab);
            make.trailing.bottom.equalTo(settingView);
            make.height.mas_equalTo(1);
        }];
    }
    
    {
        UIView *shareView = [[UIView alloc] initWithFrame:CGRectMake(0, itemHeight*2, bottomView.width, itemHeight)];
        [bottomView addSubview:shareView];
        shareView.backgroundColor = [UIColor whiteColor];
        
        UILabel *leftLab = [[UILabel alloc] init];
        [shareView addSubview:leftLab];
        leftLab.text = NSLocalizedString(@"str_share", nil);
        leftLab.font = [UIFont systemFontOfSize:17];
        leftLab.textColor = hz_1_textColor;
        [leftLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(shareView).offset(16);
            make.centerY.equalTo(shareView);
        }];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeCenter;
        [shareView addSubview:imageView];
        imageView.image = [UIImage imageNamed:@"rose_detail_share"];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(shareView).offset(-16);
            make.centerY.equalTo(shareView);
            make.width.height.mas_equalTo(28);
        }];
        
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [button setFrame:shareView.bounds];
        button.backgroundColor = [UIColor clearColor];
        [shareView addSubview:button];
        [button addTarget:self action:@selector(clickShare) forControlEvents:(UIControlEventTouchUpInside)];
        
        UIView *separater = [[UIView alloc] init];
        separater.backgroundColor = hz_1_bgColor;
        [shareView addSubview:separater];
        [separater mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(leftLab);
            make.trailing.bottom.equalTo(shareView);
            make.height.mas_equalTo(1);
        }];
    }
    
    {
        UIView *deleteView = [[UIView alloc] initWithFrame:CGRectMake(0, itemHeight*3, bottomView.width, itemHeight)];
        [bottomView addSubview:deleteView];
        deleteView.backgroundColor = [UIColor whiteColor];
        
        UILabel *leftLab = [[UILabel alloc] init];
        [deleteView addSubview:leftLab];
        leftLab.text = NSLocalizedString(@"str_delete", nil);
        leftLab.font = [UIFont systemFontOfSize:17];
        leftLab.textColor = hz_getColor(@"FF3B30");
        [leftLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(deleteView).offset(16);
            make.centerY.equalTo(deleteView);
        }];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeCenter;
        [deleteView addSubview:imageView];
        imageView.image = [UIImage imageNamed:@"rose_edit_delete"];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(deleteView).offset(-16);
            make.centerY.equalTo(deleteView);
            make.width.height.mas_equalTo(28);
        }];
        
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [button setFrame:deleteView.bounds];
        button.backgroundColor = [UIColor clearColor];
        [deleteView addSubview:button];
        [button addTarget:self action:@selector(clickDelete) forControlEvents:(UIControlEventTouchUpInside)];
    }
    
    containerView.height = bottomView.bottom + (hz_safeBottom > 0 ? hz_safeBottom : 20);
    [containerView hz_addCorner:(UIRectCornerTopLeft | UIRectCornerTopRight) radious:10];
    
    UIView *clickView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height - containerView.height)];
    clickView.backgroundColor = [UIColor clearColor];
    [self addSubview:clickView];
    @weakify(self);
    [clickView hz_clickBlock:^{
        @strongify(self);
        [self dismiss];
    }];
    
    [self show];
}

- (void)show {
    self.alpha = 0.0;
    [self.containerView setTop:self.height];
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1.0;
        [self.containerView setBottom:self.height];
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0.1;
        [self.containerView setTop:self.height];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)clickTitle {
    @weakify(self);
    HZAlertTextFieldInput *input = [[HZAlertTextFieldInput alloc] init];
    input.title = NSLocalizedString(@"str_rename", nil);
    input.cancelText = NSLocalizedString(@"str_cancel", nil);
    input.rightText = NSLocalizedString(@"str_save", nil);
    input.originText = self.project.title;
    input.cancelBlock = ^(HZAlertTextFieldView *alertView) {
        
    };
    input.rightBlock = ^(HZAlertTextFieldView *alertView) {
        @strongify(self);
        if ([HZProjectManager renameProject:self.project name:alertView.inputText]) {
            [alertView removeFromSuperview];
            [self dismiss];
        }
    };
    HZAlertTextFieldView *view = [[HZAlertTextFieldView alloc] initWithInput:input];
    [[UIView hz_viewController].view addSubview:view];
}

- (void)clickAddPsw {
    @weakify(self);
    HZAlertTextFieldInput *input = [[HZAlertTextFieldInput alloc] init];
    input.title = NSLocalizedString(@"str_setpassword", nil);
    input.cancelText = NSLocalizedString(@"str_cancel", nil);
    input.rightText = NSLocalizedString(@"str_save", nil);
    input.encrypt = YES;
    input.keyboardType = UIKeyboardTypeEmailAddress;
    input.cancelBlock = ^(HZAlertTextFieldView *alertView) {
        
    };
    input.rightBlock = ^(HZAlertTextFieldView *alertView) {
        @strongify(self);
        if (![HZCommonUtils validPassword:alertView.inputText]) {
            alertView.errorMessage = NSLocalizedString(@"str_password_format_error", nil);
            return;
        }
        self.project.openPassword = YES;
        self.project.password = alertView.inputText;
        [self.project updateInDataBase];
        [SVProgressHUD show];
        [HZPDFMaker generatePDFWithProject:self.project completeBlock:^(NSString *pdfPath) {
            @strongify(self);
            [[NSNotificationCenter defaultCenter] postNotificationName:pref_key_project_psw_changed object:self.project];
            [SVProgressHUD dismiss];
            [alertView removeFromSuperview];
            [self dismiss];
        }];
    };
    HZAlertTextFieldView *view = [[HZAlertTextFieldView alloc] initWithInput:input];
    [[UIView hz_viewController].view addSubview:view];
}
- (void)clickChangePsw {
    @weakify(self);
    HZAlertTextFieldInput *input = [[HZAlertTextFieldInput alloc] init];
    input.title = NSLocalizedString(@"str_enterpassword", nil);
    input.cancelText = NSLocalizedString(@"str_cancel", nil);
    input.rightText = NSLocalizedString(@"str_done", nil);
    input.encrypt = YES;
    input.keyboardType = UIKeyboardTypeEmailAddress;
    input.cancelBlock = ^(HZAlertTextFieldView *alertView) {
        
    };
    input.rightBlock = ^(HZAlertTextFieldView *alertView) {
        @strongify(self);
        if (![alertView.inputText isEqualToString:self.project.password]) {
            alertView.errorMessage = NSLocalizedString(@"str_password_error", nil);
            return;
        }
        
        HZChangePasswordViewController *vc = [[HZChangePasswordViewController alloc] initWithProject:self.project];
        [[UIView hz_viewController].navigationController pushViewController:vc animated:YES];
        
        [alertView removeFromSuperview];
        [self dismiss];
    };
    HZAlertTextFieldView *view = [[HZAlertTextFieldView alloc] initWithInput:input];
    [[UIView hz_viewController].view addSubview:view];
}
- (void)clickRemovePsw {
    @weakify(self);
    HZAlertTextFieldInput *input = [[HZAlertTextFieldInput alloc] init];
    input.title = NSLocalizedString(@"str_enterpassword", nil);
    input.cancelText = NSLocalizedString(@"str_cancel", nil);
    input.rightText = NSLocalizedString(@"str_done", nil);
    input.encrypt = YES;
    input.keyboardType = UIKeyboardTypeEmailAddress;
    input.cancelBlock = ^(HZAlertTextFieldView *alertView) {
        
    };
    input.rightBlock = ^(HZAlertTextFieldView *alertView) {
        @strongify(self);
        if (![alertView.inputText isEqualToString:self.project.password]) {
            alertView.errorMessage = NSLocalizedString(@"str_password_error", nil);
            return;
        }
        self.project.openPassword = NO;
        self.project.password = nil;
        [self.project updateInDataBase];
        [SVProgressHUD show];
        [HZPDFMaker generatePDFWithProject:self.project completeBlock:^(NSString *pdfPath) {
            @strongify(self);
            [[NSNotificationCenter defaultCenter] postNotificationName:pref_key_project_psw_changed object:self.project];
            [SVProgressHUD dismiss];
            [alertView removeFromSuperview];
            [self dismiss];
        }];
    };
    HZAlertTextFieldView *view = [[HZAlertTextFieldView alloc] initWithInput:input];
    [[UIView hz_viewController].view addSubview:view];
}
- (void)clickEdit {
    @weakify(self);
    [HZProjectManager duplicateTmpWithProject:self.project completeBlock:^(HZProjectModel *project) {
        @strongify(self);
        HZEditInput *input = [[HZEditInput alloc] init];
        input.project = project;
        input.originProject = self.project;
        
        HZEditViewController *vc = [[HZEditViewController alloc] initWithInput:input];
        [[UIView hz_viewController].navigationController pushViewController:vc animated:YES];
        
        [self dismiss];
    }];
}
- (void)clickSetting {
    @weakify(self);
    [HZProjectManager duplicateTmpWithProject:self.project completeBlock:^(HZProjectModel *project) {
        @strongify(self);
        HZPDFSettingViewController *vc = [[HZPDFSettingViewController alloc] initWithProject:project originalProject:self.project];
        [[UIView hz_viewController].navigationController pushViewController:vc animated:YES];
        
        [self dismiss];
    }];
}

- (void)clickShare {
    @weakify(self);
    [HZShareManager shareWithProject:self.project completionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        @strongify(self);
    }];
}

- (void)clickDelete {
    HZActionSheet *sheet = [[HZActionSheet alloc] initWithTitle:nil];
    @weakify(self);
    [sheet addDestructiveButtonWithTitle:NSLocalizedString(@"str_delete", nil) block:^{
        @strongify(self);
        [HZProjectManager deleteProject:self.project postNotification:YES completeBlock:^(HZProjectModel *project) {
            @strongify(self);
            [self dismiss];
        }];
    }];
    [sheet addCancelButtonWithTitle:NSLocalizedString(@"str_cancel", nil)];
    [sheet showInView:[UIView hz_viewController].view];
}

@end
