//
//  HZPDFPreviewViewController.m
//  RosePDF
//
//  Created by THS on 2024/2/23.
//

#import "HZPDFPreviewViewController.h"
#import "HZCommonHeader.h"
#import "HZBaseNavigationBar.h"
#import "HZPDFPreviewView.h"

@interface HZPDFPreviewViewController ()
@property (nonatomic, strong) HZProjectModel *project;

@property (nonatomic, strong) HZBaseNavigationBar *navBar;
@property (nonatomic, strong) HZPDFPreviewView *previewView;
@end

@implementation HZPDFPreviewViewController

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
    
    self.previewView = [[HZPDFPreviewView alloc] initWithProject:self.project];
    [self.view addSubview:self.previewView];
    [self.previewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(hz_safeTop + navigationHeight);
    }];
    
    [self configExitView];
}

- (void)configExitView {
    UIView *exitView = [[UIView alloc] initWithFrame:CGRectMake((self.view.width - 254)/2.0, ScreenHeight - hz_safeBottom - 20 - 56, 254, 56)];
    [self.view addSubview:exitView];
    exitView.layer.cornerRadius = 16;
    exitView.layer.masksToBounds = YES;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [exitView addSubview:blurEffectView];
    [blurEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(exitView);
    }];
    
    UIView *containerView = [[UIView alloc] init];
    [exitView addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.top.bottom.equalTo(exitView);
    }];
    
    UIImageView *close = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rose_close_black"]];
    close.contentMode = UIViewContentModeCenter;
    [containerView addSubview:close];
    [close mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.centerY.equalTo(containerView);
        make.width.height.mas_equalTo(28);
    }];
    
    UILabel *title = [[UILabel alloc] init];
    [containerView addSubview:title];
    title.font = [UIFont systemFontOfSize:17 weight:(UIFontWeightMedium)];
    title.textColor = [UIColor blackColor];
    title.text = NSLocalizedString(@"str_exit_preview", nil);
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(close.mas_trailing).offset(8);
        make.trailing.centerY.equalTo(containerView);
    }];
    
    __weak typeof(self) weakSelf = self;
    [exitView hz_clickBlock:^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - lazy
- (HZBaseNavigationBar *)navBar {
    if (!_navBar) {
        _navBar = [[HZBaseNavigationBar alloc] init];
        [_navBar configBackImage:nil];
        [_navBar configTitle:[NSString stringWithFormat:@"%@.pdf",self.project.title]];
        [_navBar configRightTitle:nil];
    }
    return _navBar;
}

@end
