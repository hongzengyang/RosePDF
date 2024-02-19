//
//  HZPDFSettingViewController.m
//  RosePDF
//
//  Created by hzy on 2024-02-19.
//

#import "HZPDFSettingViewController.h"
#import "HZCommonHeader.h"
#import "HZProjectModel.h"
#import "HZBaseNavigationBar.h"

@interface HZPDFSettingViewController ()
@property (nonatomic,strong) HZBaseNavigationBar *navBar;
@end

@implementation HZPDFSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)configView {
    [self.view addSubview:self.navBar];
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(self.view);
        make.height.mas_equalTo(hz_safeTop + navigationHeight);
    }];
}

#pragma mark -lazy
- (HZBaseNavigationBar *)navBar {
    if (!_navBar) {
        _navBar = [[HZBaseNavigationBar alloc] init];
        [_navBar configBackImage:[UIImage imageNamed:@"rose_back"]];
        [_navBar configTitle:NSLocalizedString(@"str_settings", nil)];
        [_navBar configRightTitle:nil];
        
        @weakify(self);
        _navBar.clickBackBlock = ^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        };
    }
    return _navBar;
}

@end
