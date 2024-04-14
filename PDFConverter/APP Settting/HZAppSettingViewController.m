//
//  HZAppSettingViewController.m
//  PDFConverter
//
//  Created by hzy on 2024-04-13.
//

#import "HZAppSettingViewController.h"
#import <StoreKit/StoreKit.h>
#import "HZCommonHeader.h"
#import "HZBaseNavigationBar.h"
#import "HZAppAboutViewController.h"

@interface HZAppSettingViewController ()

@property (nonatomic,strong) HZBaseNavigationBar *navBar;

@end

@implementation HZAppSettingViewController

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
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(16, self.navBar.bottom + 24, self.view.width - 32, 210)];
    containerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:containerView];
    containerView.layer.cornerRadius = 10;
    containerView.layer.masksToBounds = YES;
    
    {
        UIView *cView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, containerView.width, 70)];
        [containerView addSubview:cView];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rose_feedback"]];
        [cView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(22);
            make.centerY.equalTo(cView);
            make.leading.equalTo(cView).offset(19);
        }];
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:17];
        label.textColor = [UIColor blackColor];
        label.text = NSLocalizedString(@"str_feedback", nil);
        [cView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(imageView.mas_trailing).offset(16);
            make.centerY.equalTo(cView);
        }];
        
        UIView *separater = [[UIView alloc] init];
        [cView addSubview:separater];
        separater.backgroundColor = hz_getColorWithAlpha(@"000000", 0.3);
        [separater mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.trailing.equalTo(cView);
            make.height.mas_equalTo(0.33);
            make.leading.equalTo(imageView);
        }];
        
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [cView addSubview:button];
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(clickFeedback) forControlEvents:(UIControlEventTouchUpInside)];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cView);
        }];
    }
    
    {
        UIView *cView = [[UIView alloc] initWithFrame:CGRectMake(0, 70, containerView.width, 70)];
        [containerView addSubview:cView];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rose_rate_us"]];
        [cView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(22);
            make.centerY.equalTo(cView);
            make.leading.equalTo(cView).offset(19);
        }];
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:17];
        label.textColor = [UIColor blackColor];
        label.text = NSLocalizedString(@"str_rate", nil);
        [cView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(imageView.mas_trailing).offset(16);
            make.centerY.equalTo(cView);
        }];
        
        UIView *separater = [[UIView alloc] init];
        [cView addSubview:separater];
        separater.backgroundColor = hz_getColorWithAlpha(@"000000", 0.3);
        [separater mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.trailing.equalTo(cView);
            make.height.mas_equalTo(0.33);
            make.leading.equalTo(imageView);
        }];
        
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [cView addSubview:button];
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(clickRateUs) forControlEvents:(UIControlEventTouchUpInside)];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cView);
        }];
    }
    
    {
        UIView *cView = [[UIView alloc] initWithFrame:CGRectMake(0, 140, containerView.width, 70)];
        [containerView addSubview:cView];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rose_about"]];
        [cView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(22);
            make.centerY.equalTo(cView);
            make.leading.equalTo(cView).offset(19);
        }];
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:17];
        label.textColor = [UIColor blackColor];
        label.text = NSLocalizedString(@"str_about", nil);
        [cView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(imageView.mas_trailing).offset(16);
            make.centerY.equalTo(cView);
        }];
        
        UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rose_arrow"]];
        [cView addSubview:arrow];
        [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.width.height.mas_equalTo(28);
            make.trailing.equalTo(cView).offset(-16);
            make.centerY.equalTo(cView);
        }];
        
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [cView addSubview:button];
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(clickAbout) forControlEvents:(UIControlEventTouchUpInside)];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cView);
        }];
    }
}

- (void)clickFeedback {
    
}

- (void)clickRateUs {
    [SKStoreReviewController requestReview];
}

- (void)clickAbout {
    HZAppAboutViewController *vc = [[HZAppAboutViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -lazy
- (HZBaseNavigationBar *)navBar {
    if (!_navBar) {
        _navBar = [[HZBaseNavigationBar alloc] init];
        [_navBar configBackImage:[UIImage imageNamed:@"rose_back"]];
        [_navBar configTitle:NSLocalizedString(@"str_settings", nil)];
        [_navBar configRightTitle:nil];
        [_navBar setVisualEffectHidden:YES];
        [_navBar setSeparaterHidden:YES];
        @weakify(self);
        _navBar.clickBackBlock = ^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        };
    }
    return _navBar;
}

@end
