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

@interface HZHomeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) HZHomeNavigationBar *navBar;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation HZHomeViewController
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = hz_1_bgColor;
    
    [self configView];
}

- (void)configView {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.navBar];
    
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.height.mas_equalTo(hz_safeTop + 54);
    }];
    
    UIView *gradientView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - hz_safeBottom - 100, ScreenWidth, 100)];
    [self.view addSubview:gradientView];
    [gradientView hz_addGradientWithColors:@[hz_getColorWithAlpha(@"F2F1F6", 0.0),hz_getColorWithAlpha(@"F2F1F6", 1.0)] startPoint:CGPointMake(0.5, 0) endPoint:CGPointMake(0.5, 1.0)];
    
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark click
- (void)clickAddButton {
    
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 116.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return nil;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

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

#pragma mark - Lazy
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - hz_safeBottom) style:(UITableViewStylePlain)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = hz_1_bgColor;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        HZHomeTableHeaderView *header = [[HZHomeTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, hz_safeTop + 158)];
        _tableView.tableHeaderView = header;
        if (@available(iOS 11.0, *)){
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _tableView;
}
- (HZHomeNavigationBar *)navBar {
    if (!_navBar) {
        _navBar = [[HZHomeNavigationBar alloc] init];
    }
    return _navBar;
}

@end
