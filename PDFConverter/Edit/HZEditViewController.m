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
#import "HZPDFSettingViewController.h"
#import "HZSortViewController.h"
#import "HZEditFilterView.h"
#import <YYModel/NSObject+YYModel.h>
#import "HZCropViewController.h"

@interface HZEditViewController ()<HZEditBottomViewDelegate>

@property (nonatomic, strong) HZEditInput *input;

@property (nonatomic, strong) HZBaseNavigationBar *navBar;
@property (nonatomic, strong) HZEditTopCollectionView *topView;
@property (nonatomic, strong) HZEditPreviewCollectionView *previewView;
@property (nonatomic, strong) HZEditBottomView *bottomView;
@property (nonatomic, strong) HZEditFilterView *filterView;

@property (nonatomic, strong) HZEditDataboard *databoard;

@end

@implementation HZEditViewController

- (instancetype)initWithInput:(HZEditInput *)input {
    if (self = [super init]) {
        self.input = input;
        
        self.databoard.project = input.project;
        self.databoard.originProject = input.originProject;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addAssetsFinished) name:pref_key_add_assets_finished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sortFinish:) name:pref_key_sort_finish object:nil];
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
        make.top.equalTo(self.navBar.mas_bottom).offset(88);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
}

- (void)reloadAll {
    [self.topView reloadAll];
    [self.previewView reloadAll];
}

- (void)reloadCurrent {
    [self.topView reloadCurrent];
    [self.previewView reloadAll];
}

#pragma mark - Filter
- (void)enterFilterMode {
    if (!self.filterView) {
        self.filterView = [[HZEditFilterView alloc] initWithFrame:CGRectMake(0, self.view.height, self.view.width, 28 + 10 + 154 + hz_safeBottom) databoard:self.databoard];
        [self.view addSubview:self.filterView];
        @weakify(self);
        self.filterView.slideBlock = ^(BOOL isFilter, HZFilterType filterType, HZAdjustType adjustType) {
            @strongify(self);
            [self.previewView renderCurrentPreviewImage];
        };
        
        self.filterView.clickFilterItemBlock = ^(HZFilterType filterType) {
            @strongify(self);
            [self.previewView renderCurrentPreviewImage];
        };
        
        self.filterView.completeBlock = ^(BOOL applyAll) {
            @strongify(self);
            [self handleFilterComplete:applyAll];
        };
    }
    
    [self.filterView update];
    
    self.filterView.top = self.view.height;
    [UIView animateWithDuration:0.25 animations:^{
        self.filterView.bottom = self.view.bottom;
    }];
    self.databoard.isFilterMode = YES;
    [self.navBar setBackHidden:YES];
    [self.navBar setRightHidden:YES];
}

- (void)exitFilterMode {
    [UIView animateWithDuration:0.25 animations:^{
        self.filterView.top = self.view.height;
    }];
    self.databoard.isFilterMode = NO;
    [self.navBar setBackHidden:NO];
    [self.navBar setRightHidden:NO];
}

- (void)handleFilterComplete:(BOOL)applyToAll {
    HZPageModel *curPage = [self.databoard currentPage];
    
    NSMutableArray <HZPageModel *>*pages = [[NSMutableArray alloc] init];
    if (applyToAll) {
        [pages addObjectsFromArray:self.databoard.project.pageModels];
        [pages enumerateObjectsUsingBlock:^(HZPageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.filter = [HZFilterModel yy_modelWithJSON:[curPage.filter yy_modelToJSONData]];
            obj.adjust = [HZAdjustModel yy_modelWithJSON:[curPage.adjust yy_modelToJSONData]];
        }];
    }else {
        if (curPage) {
            [pages addObject:curPage];
        }
    }
    
    if (pages.count == 0) {
        [self exitFilterMode];
        return;
    }

    [SVProgressHUD show];
    @weakify(self);
    [HZPageModel writeResultFileWithPages:pages completeBlock:^{
        @strongify(self);
        [SVProgressHUD dismiss];
        [self exitFilterMode];
        if (applyToAll) {
            [self reloadAll];
        }else {
            [self reloadCurrent];
        }
    }];
}

#pragma mark - Crop
- (void)handleCropFinish {
    [self reloadCurrent];
}

#pragma mark - 通知
- (void)addAssetsFinished {
    [self reloadAll];
    [self.bottomView checkDeleteEnable];
}

- (void)sortFinish:(NSNotification *)not {
    NSArray <HZPageModel *>*pages = not.object;
    
    self.databoard.project.pageModels = pages;
    [self reloadAll];
}

#pragma mark - HZEditBottomViewDelegate
- (void)editBottomViewClickItem:(HZEditBottomItem)item {
    @weakify(self);
    HZPageModel *currenrPage = [self.databoard currentPage];
    if (item == HZEditBottomItemFilter) {
        if (!self.databoard.isFilterMode) {
            [self enterFilterMode];
        }
    }else if (item == HZEditBottomItemLeft) {
        HZPageOrientation orientation = currenrPage.orientation;
        switch (orientation) {
            case HZPageOrientation_up:
                orientation = HZPageOrientation_left;
                break;
            case HZPageOrientation_left:
                orientation = HZPageOrientation_down;
                break;
            case HZPageOrientation_down:
                orientation = HZPageOrientation_right;
                break;
            case HZPageOrientation_right:
                orientation = HZPageOrientation_up;
                break;
            default:
                break;
        }
        currenrPage.orientation = orientation;
        [SVProgressHUD show];
        [currenrPage writeResultFileWithCompleteBlock:^(UIImage *result) {
            @strongify(self);
            [SVProgressHUD dismiss];
            [self reloadCurrent];
        }];
    }else if (item == HZEditBottomItemRight) {
        HZPageOrientation orientation = currenrPage.orientation;
        switch (orientation) {
            case HZPageOrientation_up:
                orientation = HZPageOrientation_right;
                break;
            case HZPageOrientation_right:
                orientation = HZPageOrientation_down;
                break;
            case HZPageOrientation_down:
                orientation = HZPageOrientation_left;
                break;
            case HZPageOrientation_left:
                orientation = HZPageOrientation_up;
                break;
            default:
                break;
        }
        currenrPage.orientation = orientation;
        [SVProgressHUD show];
        [currenrPage writeResultFileWithCompleteBlock:^(UIImage *result) {
            @strongify(self);
            [SVProgressHUD dismiss];
            [self reloadCurrent];
        }];
    }else if (item == HZEditBottomItemCrop) {
        HZCropViewController *vc = [[HZCropViewController alloc] initWithPageModel:currenrPage];
        vc.cropFinishBlock = ^{
            @strongify(self);
            [self handleCropFinish];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }else if (item == HZEditBottomItemReorder) {
        HZSortViewController *vc = [[HZSortViewController alloc] initWithPages:[self.databoard.project.pageModels copy]];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (item == HZEditBottomItemDelete) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle: UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"str_cancel", nil) style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"str_delete", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            @strongify(self);
            NSMutableArray *muArray = [self.databoard.project.pageModels mutableCopy];
            [muArray removeObjectAtIndex:self.databoard.currentIndex];
            self.databoard.project.pageModels = [muArray copy];
            if (self.databoard.currentIndex >= self.databoard.project.pageModels.count) {
                self.databoard.currentIndex = self.databoard.project.pageModels.count - 1;
            }
            [self reloadAll];
            [self.bottomView checkDeleteEnable];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:deleteAction];

        if ([[HZSystemManager manager] iPadDevice]) {
            alertController.popoverPresentationController.sourceView = self.bottomView.deleteBtn;
            alertController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
            alertController.popoverPresentationController.sourceRect = CGRectMake(self.bottomView.deleteBtn.width/2.0, 0, 0, 0);
        }
        [[UIView hz_viewController] presentViewController:alertController animated:YES completion:nil];
    }
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
            [HZProjectManager deleteProject:self.databoard.project postNotification:YES completeBlock:^(HZProjectModel *project) {
                @strongify(self);
                [self.navigationController popViewControllerAnimated:YES];
            }];
        };
        _navBar.clickRightBlock = ^{
            @strongify(self);
            HZPDFSettingViewController *vc = [[HZPDFSettingViewController alloc] initWithProject:self.input.project originalProject:self.input.originProject];
            [self.navigationController pushViewController:vc animated:YES];
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
