//
//  HZAppAboutViewController.m
//  PDFConverter
//
//  Created by hzy on 2024-04-14.
//

#import "HZAppAboutViewController.h"
#import "HZCommonHeader.h"
#import "HZBaseNavigationBar.h"
#import "HZPDFWebViewController.h"

@interface HZAppAboutViewController ()

@property (nonatomic,strong) HZBaseNavigationBar *navBar;

@end

@implementation HZAppAboutViewController

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
    
    BOOL isChina = [[HZSystemManager manager] isChina];
    CGFloat height = isChina ? 210 : 140;
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(16, self.navBar.bottom + 24, self.view.width - 32, height)];
    containerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:containerView];
    containerView.layer.cornerRadius = 10;
    containerView.layer.masksToBounds = YES;
    
    {
        UIView *cView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, containerView.width, 70)];
        [containerView addSubview:cView];
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:17];
        label.textColor = [UIColor blackColor];
        label.text = NSLocalizedString(@"str_privacy", nil);
        [cView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(cView).offset(16);
            make.centerY.equalTo(cView);
        }];
        
        UIView *separater = [[UIView alloc] init];
        [cView addSubview:separater];
        separater.backgroundColor = hz_getColorWithAlpha(@"000000", 0.3);
        [separater mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.trailing.equalTo(cView);
            make.height.mas_equalTo(0.33);
            make.leading.equalTo(label);
        }];
        
        UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rose_arrow"]];
        [cView addSubview:arrow];
        [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(cView).offset(-16);
            make.centerY.equalTo(cView);
        }];
        
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [cView addSubview:button];
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(clickPrivacyolicy) forControlEvents:(UIControlEventTouchUpInside)];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cView);
        }];
    }
    
    {
        UIView *cView = [[UIView alloc] initWithFrame:CGRectMake(0, 70, containerView.width, 70)];
        [containerView addSubview:cView];
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:17];
        label.textColor = [UIColor blackColor];
        label.text = NSLocalizedString(@"str_terms", nil);
        [cView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(cView).offset(16);
            make.centerY.equalTo(cView);
        }];
        
        if (isChina) {
            UIView *separater = [[UIView alloc] init];
            [cView addSubview:separater];
            separater.backgroundColor = hz_getColorWithAlpha(@"000000", 0.3);
            [separater mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.trailing.equalTo(cView);
                make.height.mas_equalTo(0.33);
                make.leading.equalTo(label);
            }];
        }
        
        UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rose_arrow"]];
        [cView addSubview:arrow];
        [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(cView).offset(-16);
            make.centerY.equalTo(cView);
        }];
        
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [cView addSubview:button];
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(clickTerms) forControlEvents:(UIControlEventTouchUpInside)];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cView);
        }];
    }
    
    if (isChina) {
        UIView *cView = [[UIView alloc] initWithFrame:CGRectMake(0, 140, containerView.width, 70)];
        [containerView addSubview:cView];
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:17];
        label.textColor = [UIColor blackColor];
        label.text = @"ICP";
        [cView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(cView).offset(16);
            make.centerY.equalTo(cView);
        }];
        
        UILabel *labelRight = [[UILabel alloc] init];
        labelRight.font = [UIFont systemFontOfSize:15];
        labelRight.textAlignment = NSTextAlignmentRight;
        labelRight.textColor = hz_getColor(@"666666");
        labelRight.text = @"浙ICP备2023040298号-5A";
        [cView addSubview:labelRight];
        [labelRight mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(cView).offset(-16);
            make.centerY.equalTo(cView);
        }];
    }
}

- (void)clickPrivacyolicy {
    HZPDFWebViewController *vc = [[HZPDFWebViewController alloc] initWithUrl:[[NSBundle mainBundle] pathForResource:@"PrivacyPolicy" ofType:@"pdf"] title:NSLocalizedString(@"str_privacy", nil)];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clickTerms {
    HZPDFWebViewController *vc = [[HZPDFWebViewController alloc] initWithUrl:[[NSBundle mainBundle] pathForResource:@"Terms_Conditions" ofType:@"pdf"] title:NSLocalizedString(@"str_terms", nil)];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark -lazy
- (HZBaseNavigationBar *)navBar {
    if (!_navBar) {
        _navBar = [[HZBaseNavigationBar alloc] init];
        [_navBar configBackImage:[UIImage imageNamed:@"rose_back"]];
        [_navBar configTitle:NSLocalizedString(@"str_about", nil)];
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
