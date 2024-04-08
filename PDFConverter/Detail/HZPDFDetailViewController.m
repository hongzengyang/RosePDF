//
//  HZPDFDetailViewController.m
//  RosePDF
//
//  Created by THS on 2024/2/26.
//

#import "HZPDFDetailViewController.h"
#import "HZCommonHeader.h"
#import "HZBaseNavigationBar.h"
#import "HZDetailBottomView.h"
#import "HZAlertTextFieldView.h"
#import "HZProjectManager.h"
#import "HZPDFPreviewView.h"
#import "HZPDFSettingViewController.h"
#import "HZEditViewController.h"
#import "HZDetailPasswordView.h"
#import <HZUIKit/HZActionSheet.h>
#import "HZShareManager.h"

@interface HZPDFDetailViewController ()<HZDetailBottomViewDelegate>
@property (nonatomic, strong) HZProjectModel *project;

@property (nonatomic, strong) HZBaseNavigationBar *navBar;
@property (nonatomic, strong) HZDetailBottomView *bottomView;
@property (nonatomic, strong) HZPDFPreviewView *previewView;
@property (nonatomic, strong) HZDetailPasswordView *passwordView;
@end

@implementation HZPDFDetailViewController

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
    
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.height.mas_equalTo(hz_safeBottom + 49);
    }];
    
    self.previewView = [[HZPDFPreviewView alloc] initWithProject:self.project];
    [self.view addSubview:self.previewView];
    [self.previewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.navBar.mas_bottom);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
    
    self.passwordView = [[HZDetailPasswordView alloc] initWithProject:self.project];
    [self.view addSubview:self.passwordView];
    [self.passwordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.top.equalTo(self.navBar.mas_bottom);
    }];
    @weakify(self);
    self.passwordView.openSuccessBlock = ^{
        @strongify(self);
        self.passwordView.hidden = YES;
        [self.passwordView configFirstResponder:NO];
    };
    
    if (self.project.openPassword && self.project.password.length > 0) {
        self.passwordView.hidden = NO;
        [self.passwordView configFirstResponder:YES];
    }else {
        self.passwordView.hidden = YES;
        [self.passwordView configFirstResponder:NO];
    }
}

#pragma mark - HZDetailBottomViewDelegate
- (void)detailBottomViewClickItem:(HZDetailBottomItem)item {
    @weakify(self);
    if (item == HZDetailBottomItemShare) {
        HZShareParam *param = [[HZShareParam alloc] init];
        param.project = self.project;
        param.relatedView = self.bottomView.shareBtn;
        param.arrowDirection = UIPopoverArrowDirectionDown;
        [HZShareManager shareWithParam:param completionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
                
        }];
    }else if (item == HZDetailBottomItemRename) {
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
                [self.navBar configTitle:alertView.inputText];
                [alertView removeFromSuperview];
            }
        };
        HZAlertTextFieldView *view = [[HZAlertTextFieldView alloc] initWithInput:input];
        [self.view addSubview:view];
    }else if (item == HZDetailBottomItemEdit) {
        [HZProjectManager duplicateTmpWithProject:self.project completeBlock:^(HZProjectModel *project) {
            @strongify(self);
            
            HZEditInput *input = [[HZEditInput alloc] init];
            input.project = project;
            input.originProject = self.project;
            
            HZEditViewController *vc = [[HZEditViewController alloc] initWithInput:input];
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }else if (item == HZDetailBottomItemSetting) {
        [HZProjectManager duplicateTmpWithProject:self.project completeBlock:^(HZProjectModel *project) {
            @strongify(self);
            HZPDFSettingViewController *vc = [[HZPDFSettingViewController alloc] initWithProject:project originalProject:self.project];
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }else if (item == HZDetailBottomItemDelete) {
        HZActionSheet *sheet = [[HZActionSheet alloc] initWithTitle:nil];
        [sheet addDestructiveButtonWithTitle:NSLocalizedString(@"str_delete", nil) block:^{
            @strongify(self);
            [HZProjectManager deleteProject:self.project postNotification:YES completeBlock:^(HZProjectModel *project) {
                @strongify(self);
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
        [sheet addCancelButtonWithTitle:NSLocalizedString(@"str_cancel", nil)];
        [sheet showInView:self.view];
    }
}

#pragma mark - Lazy
- (HZBaseNavigationBar *)navBar {
    if (!_navBar) {
        _navBar = [[HZBaseNavigationBar alloc] init];
        [_navBar configBackImage:[UIImage imageNamed:@"rose_close"]];
        [_navBar configTitle:self.project.title];
        [_navBar configRightTitle:nil];
        
        @weakify(self);
        _navBar.clickBackBlock = ^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        };
    }
    return _navBar;
}

- (HZDetailBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[HZDetailBottomView alloc] initWithProject:self.project];
        _bottomView.delegate = self;
    }
    return _bottomView;
}

@end
