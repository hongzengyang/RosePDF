//
//  HZEditViewController.m
//  RosePDF
//
//  Created by THS on 2024/2/18.
//

#import "HZEditViewController.h"
#import "HZCommonHeader.h"
#import "HZProjectModel.h"
#import "HZBaseNavigationBar.h"
#import "HZEditTopCollectionView.h"
#import "HZEditPreviewCollectionView.h"
#import "HZEditBottomView.h"
#import "HZEditDataboard.h"
#import "HZProjectManager.h"

@implementation HZEditInput
@end

@interface HZEditViewController ()<HZEditBottomViewDelegate>

@property (nonatomic, strong) HZBaseNavigationBar *navBar;
@property (nonatomic, strong) HZEditTopCollectionView *topView;
@property (nonatomic, strong) HZEditPreviewCollectionView *previewView;
@property (nonatomic, strong) HZEditBottomView *bottomView;

@property (nonatomic, strong) HZEditDataboard *databoard;

@end

@implementation HZEditViewController

- (instancetype)initWithInput:(HZEditInput *)input {
    if (self = [super init]) {
        self.databoard.project = input.project;
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
    
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo(88);
        make.top.equalTo(self.navBar.mas_bottom);
    }];
    
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.height.mas_equalTo(hz_safeBottom + 49);
    }];
    
    [self.view addSubview:self.previewView];
    [self.previewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.topView.mas_bottom);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
}

#pragma mark - HZEditBottomViewDelegate
-(void)editBottomViewClickItem:(HZEditBottomItem)item {
    
}

#pragma mark - Lazy
- (HZBaseNavigationBar *)navBar {
    if (!_navBar) {
        _navBar = [[HZBaseNavigationBar alloc] init];
        [_navBar configBackImage:[UIImage imageNamed:@"rose_back"]];
        [_navBar configTitle:NSLocalizedString(@"str_edit", nil)];
        [_navBar configRightTitle:NSLocalizedString(@"str_next", nil)];
        
        @weakify(self);
        _navBar.clickBackBlock = ^{
            @strongify(self);
            [HZProjectManager deleteProject:self.databoard.project];
            [self.navigationController popViewControllerAnimated:YES];
        };
        _navBar.clickRightBlock = ^{
            @strongify(self);
        };
    }
    return _navBar;
}

- (HZEditTopCollectionView *)topView {
    if (!_topView) {
        _topView = [[HZEditTopCollectionView alloc] initWithDataboard:self.databoard];
    }
    return _topView;
}

- (HZEditBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[HZEditBottomView alloc] initWithDataboard:self.databoard];
        _bottomView.delegate = self;
    }
    return _bottomView;
}

- (HZEditPreviewCollectionView *)previewView {
    if (!_previewView) {
        _previewView = [[HZEditPreviewCollectionView alloc] initWithDataboard:self.databoard];
    }
    return _previewView;
}

- (HZEditDataboard *)databoard {
    if (!_databoard) {
        _databoard = [[HZEditDataboard alloc] init];
    }
    return _databoard;
}

@end
