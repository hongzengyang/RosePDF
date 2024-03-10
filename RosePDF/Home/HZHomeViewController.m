//
//  HZHomeViewController.m
//  RosePDF
//
//  Created by THS on 2024/2/4.
//

#import "HZHomeViewController.h"
#import "HZCommonHeader.h"
#import "HZHomeNavigationBar.h"
#import "HZHomeTableHeaderView.h"
#import "HZEditViewController.h"
#import "HZProjectModel.h"
#import <HZAssetsPicker/HZAssetsPickerViewController.h>
#import <HZAssetsPicker/HZAssetsPickerManager.h>
#import "HZProjectManager.h"
#import "HZAlertTextFieldView.h"
#import "HZPDFDetailViewController.h"
#import "HZHomeCell.h"

@interface HZHomeViewController ()<UITableViewDelegate,UITableViewDataSource,HZHomeNavigationBarDelegate>

@property (nonatomic, strong) NSArray <HZProjectModel *>*projects;

@property (nonatomic, strong) HZHomeNavigationBar *navBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *emptyLab;
@property (nonatomic, strong) UIView *deleteView;
@property (nonatomic, strong) UIButton *addBtn;

@property (nonatomic, assign) BOOL multiSelectMode;
@property (nonatomic, strong) NSMutableArray <HZProjectModel *>*selectProjects;
@end

@implementation HZHomeViewController
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectProjects = [[NSMutableArray alloc] init];
    
    [self configView];
    [self requestData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectUpdate:) name:pref_key_update_project object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectDelete:) name:pref_key_delete_project object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectRename:) name:pref_key_rename_project object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectPasswordChanged:) name:pref_key_project_psw_changed object:nil];
    
    [HZProjectManager cleanTmpProjects];
}

- (void)configView {
    self.view.backgroundColor = hz_1_bgColor;
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.navBar];
    
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.height.mas_equalTo(hz_safeTop + 54);
    }];
    
    UIView *gradientView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - hz_safeBottom - 100, ScreenWidth, 100)];
    [self.view addSubview:gradientView];
    [gradientView hz_addGradientWithColors:@[hz_getColorWithAlpha(@"F2F1F6", 0.0),hz_getColorWithAlpha(@"F2F1F6", 1.0)] startPoint:CGPointMake(0.5, 0) endPoint:CGPointMake(0.5, 1.0)];
    
    [self.view addSubview:self.deleteView];
    
    UIButton *addBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.view addSubview:addBtn];
    [addBtn setImage:[UIImage imageNamed:@"rose_home_add"] forState:(UIControlStateNormal)];
    [addBtn setImage:[UIImage imageNamed:@"rose_home_add"] forState:(UIControlStateHighlighted)];
    [addBtn addTarget:self action:@selector(clickAddButton) forControlEvents:(UIControlEventTouchUpInside)];
    [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-(hz_safeBottom + 8));
        make.width.height.mas_equalTo(86);
        make.centerX.equalTo(self.view);
    }];
    self.addBtn = addBtn;
}

- (void)requestData {
    self.projects = [HZProjectModel queryAllProjects];
    [self.tableView reloadData];
    
    if (self.projects.count > 0) {
        self.emptyLab.hidden = YES;
    }else {
        self.emptyLab.hidden = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark click
- (void)clickAddButton {
    @weakify(self);
    [HZAssetsPickerManager requestAuthorizationWithCompleteBlock:^(BOOL complete) {
        @strongify(self);
        if (!complete) {//用户拒绝
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"str_photo_permission_deny_title", nil)
                                                                                     message:NSLocalizedString(@"str_photo_permission_deny_tip", nil)
                                                                              preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"str_cancel", nil) style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"str_go_setting", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                // 跳转到应用设置页面
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                                   options:@{}
                                         completionHandler:nil];
            }];

            [alertController addAction:cancelAction];
            [alertController addAction:settingsAction];

            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
        HZAssetsPickerViewController *assetPicker = [[HZAssetsPickerViewController alloc] init];
        assetPicker.SelectImageBlock = ^(NSArray<UIImage *> * _Nonnull images) {
            @strongify(self);
            HZProjectModel *project = [HZProjectManager createProjectWithFolderId:Default_folderId isTmp:YES];
            [SVProgressHUD show];
            [HZProjectManager addPagesWithImages:images inProject:project completeBlock:^(NSArray<HZPageModel *> *pages) {
                @strongify(self);
                [SVProgressHUD dismiss];
                HZEditInput *input = [[HZEditInput alloc] init];
                input.project = project;
                
                HZEditViewController *edit = [[HZEditViewController alloc] initWithInput:input];
                [self.navigationController pushViewController:edit animated:YES];
            }];
        };
        [self.navigationController pushViewController:assetPicker animated:YES];
        
    }];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 116.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    HZHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HZHomeCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    HZProjectModel *project = [self.projects objectAtIndex:indexPath.row];
    [cell configWithProject:project isSelectMode:self.multiSelectMode isSelect:[self.selectProjects containsObject:project]];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.projects.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HZProjectModel *project = [self.projects objectAtIndex:indexPath.row];
    if (self.multiSelectMode) {
        if ([self.selectProjects containsObject:project]) {
            [self.selectProjects removeObject:project];
        }else {
            [self.selectProjects addObject:project];
        }
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationNone)];
        return;
    }
    
    HZPDFDetailViewController *vc = [[HZPDFDetailViewController alloc] initWithProject:project];
    [self.navigationController pushViewController:vc animated:YES];
    
    if (project.newFlag) {
        project.newFlag = NO;
        [project updateInDataBase];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationNone)];
    }
}

#pragma mark - UIScrollView
static CGFloat prevOffsetY = 0;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat value = 22;
    if (scrollView.contentOffset.y >= value && prevOffsetY < value) {
        [self.navBar configSwipeUpMode:YES];
    }else if (scrollView.contentOffset.y <= value && prevOffsetY > value) {
        [self.navBar configSwipeUpMode:NO];
    }
    prevOffsetY = scrollView.contentOffset.y;
    [self.view endEditing:YES];
}

#pragma mark - HZHomeNavigationBarDelegate
- (void)clickMultiSelectButton {
    [self enterSelectMode];
}
- (void)clickAppSettingsButton {
    
}

- (void)clickSelectAllButton {
    [self.selectProjects removeAllObjects];
    [self.selectProjects addObjectsFromArray:self.projects];
    [self.tableView reloadData];
}
- (void)clickCancelSelectAllButton {
    [self.selectProjects removeAllObjects];
    [self.tableView reloadData];
}
- (void)clickSelectFinishButton {
    [self.selectProjects removeAllObjects];
    [self exitSelectMode];
    [self.navBar configSelectMode:NO];
}

#pragma mark -- 多选
- (void)enterSelectMode {
    self.multiSelectMode = YES;
    [self.tableView reloadData];
    
    self.addBtn.hidden = YES;
    [UIView animateWithDuration:0.25 animations:^{
        self.deleteView.bottom = ScreenHeight - hz_safeBottom - 20;
    }];
}

- (void)exitSelectMode {
    self.multiSelectMode = NO;
    [self.tableView reloadData];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.deleteView.top = ScreenHeight;
    } completion:^(BOOL finished) {
        self.addBtn.hidden = NO;
    }];
}

- (void)clickDeleteButton {
    __block NSInteger callback = 0;
    NSInteger total = self.selectProjects.count;
    [self.selectProjects enumerateObjectsUsingBlock:^(HZProjectModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [HZProjectManager deleteProject:obj postNotification:NO completeBlock:^(HZProjectModel *project) {
            callback++;
            if (callback == total) {
                [self.selectProjects removeAllObjects];
                [self requestData];
                [self exitSelectMode];
                [self.navBar configSelectMode:NO];
            }
        }];
    }];
}

#pragma mark - 通知
- (void)projectUpdate:(NSNotification *)not {
    HZProjectModel *project = not.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self requestData];
    });
}
- (void)projectDelete:(NSNotification *)not {
    HZProjectModel *project = not.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self requestData];
    });
}
- (void)projectRename:(NSNotification *)not {
    HZProjectModel *project = not.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self requestData];
    });
}

- (void)projectPasswordChanged:(NSNotification *)not {
    HZProjectModel *project = not.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self requestData];
    });
}

#pragma mark - Lazy
- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - hz_safeBottom) style:(UITableViewStylePlain)];
        _tableView = tableView;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[HZHomeCell class] forCellReuseIdentifier:@"HZHomeCell"];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
        
        HZHomeTableHeaderView *header = [[HZHomeTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, hz_safeTop + 158)];
        _tableView.tableHeaderView = header;
        if (@available(iOS 11.0, *)){
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        self.emptyLab = [[UILabel alloc] init];
        self.emptyLab.font = [UIFont systemFontOfSize:20];
        self.emptyLab.textColor = hz_getColor(@"999999");
        [_tableView addSubview:self.emptyLab];
        self.emptyLab.text = NSLocalizedString(@"str_home_empty_file", nil);
        [self.emptyLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(tableView);
            make.centerY.equalTo(tableView).offset(50);
        }];
    }
    return _tableView;
}
- (HZHomeNavigationBar *)navBar {
    if (!_navBar) {
        _navBar = [[HZHomeNavigationBar alloc] init];
        _navBar.delegate = self;
    }
    return _navBar;
}

- (UIView *)deleteView {
    if (!_deleteView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake((ScreenWidth - 254)/2.0, ScreenHeight, 254, 56)];
        view.backgroundColor = [UIColor whiteColor];
        _deleteView = view;
        _deleteView.layer.cornerRadius = 16;
        _deleteView.layer.masksToBounds = YES;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:@"rose_edit_delete"];
        [_deleteView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(24);
            make.leading.equalTo(view).offset(84);
            make.centerY.equalTo(view);
        }];
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:17 weight:(UIFontWeightBold)];
        label.text = NSLocalizedString(@"str_delete", nil);
        label.textColor = hz_getColor(@"FF3B30");
        [view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(view);
            make.leading.equalTo(imageView.mas_trailing).offset(4);
        }];
        
        UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [view addSubview:btn];
        btn.backgroundColor = [UIColor clearColor];
        [btn addTarget:self action:@selector(clickDeleteButton) forControlEvents:(UIControlEventTouchUpInside)];
        btn.frame = view.bounds;
    }
    return _deleteView;
}

@end
