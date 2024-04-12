//
//  HZSearchViewController.m
//  RosePDF
//
//  Created by THS on 2024/3/11.
//

#import "HZSearchViewController.h"
#import "HZCommonHeader.h"
#import "HZEditViewController.h"
#import "HZProjectModel.h"
#import "HZProjectManager.h"
#import "HZPDFDetailViewController.h"
#import "HZHomeCell.h"

@interface HZSearchViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray <HZProjectModel *>*projects;

@property (nonatomic, strong) UIView *navBar;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation HZSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectUpdate:) name:pref_key_update_project object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectDelete:) name:pref_key_delete_project object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectRename:) name:pref_key_rename_project object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectPasswordChanged:) name:pref_key_project_psw_changed object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)configView {
    self.view.backgroundColor = hz_1_bgColor;
    
    [self.view addSubview:self.navBar];
    [self.view addSubview:self.tableView];
}

- (void)clickCancelButton {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)clickClearButton {
    self.textField.text = @"";
}

- (void)startSearch {
    self.projects = [HZProjectModel searchWithText:self.textField.text];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 116.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    HZHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HZHomeCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    HZProjectModel *project = [self.projects objectAtIndex:indexPath.row];
    [cell configWithProject:project isSelectMode:NO isSelect:NO];
    
    @weakify(self);
    cell.clickMoreBlock = ^{
        @strongify(self);
        if ([self.textField isFirstResponder]) {
            [self.textField resignFirstResponder];
        }
    };
    cell.clickShareBlock = ^{
        @strongify(self);
        if ([self.textField isFirstResponder]) {
            [self.textField resignFirstResponder];
        }
    };
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.projects.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HZProjectModel *project = [self.projects objectAtIndex:indexPath.row];
    
    HZPDFDetailViewController *vc = [[HZPDFDetailViewController alloc] initWithProject:project];
    [self.navigationController pushViewController:vc animated:YES];
    
    if (project.newFlag) {
        project.newFlag = NO;
        [project updateInDataBase];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationNone)];
    }
    
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        [self startSearch];
        return NO;
    }
    return YES;
}

- (void)onTextFieldChanged:(UITextField *)textField {
    [self startSearch];
}


#pragma mark - 通知
- (void)projectUpdate:(NSNotification *)not {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startSearch];
    });
}
- (void)projectDelete:(NSNotification *)not {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startSearch];
    });
}
- (void)projectRename:(NSNotification *)not {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startSearch];
    });
}

- (void)projectPasswordChanged:(NSNotification *)not {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startSearch];
    });
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
            textField.tintColor = hz_getColor(@"000000");
            textField.textColor = hz_getColor(@"888888");
            textField.font = [UIFont systemFontOfSize:16];
            [textField addTarget:self action:@selector(onTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
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

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.navBar.bottom, self.view.width, self.view.height - self.navBar.bottom) style:(UITableViewStylePlain)];
        tableView.backgroundColor = hz_1_bgColor;
        _tableView = tableView;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[HZHomeCell class] forCellReuseIdentifier:@"HZHomeCell"];
        _tableView.contentInset = UIEdgeInsetsMake(20, 0, 100, 0);
        
        if (@available(iOS 11.0, *)){
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _tableView;
}
@end

