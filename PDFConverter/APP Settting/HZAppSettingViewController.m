//
//  HZAppSettingViewController.m
//  PDFConverter
//
//  Created by hzy on 2024-04-13.
//

#import "HZAppSettingViewController.h"
#import <HZUIKit/HZAlertView.h>
#import <YYCategories/UIDevice+YYAdd.h>
#import <MessageUI/MessageUI.h>
#import <StoreKit/StoreKit.h>
#import "HZCommonHeader.h"
#import "HZBaseNavigationBar.h"
#import "HZAppAboutViewController.h"

@interface HZAppSettingViewController ()<MFMailComposeViewControllerDelegate>

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
        separater.backgroundColor = hz_getColorWithAlpha(@"000000", 0.1);
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
        separater.backgroundColor = hz_getColorWithAlpha(@"000000", 0.1);
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
    
    {//version
        UILabel *label = [[UILabel alloc] init];
        label.textColor = hz_2_textColor;
        [self.view addSubview:label];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.text = [NSString stringWithFormat:@"Version: %@",[ [[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.view).offset(10);
            make.trailing.equalTo(self.view).offset(-10);
            make.bottom.equalTo(self.view).offset(-hz_safeBottom - 30);
        }];
        
    }
}

- (void)clickFeedback {
    if (![self checkEmailEnable]) {
        HZAlertView *alertView = [[HZAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"str_setup_email_title", nil)];
        __weak typeof(self) weakSelf = self;
        [alertView addCancelButtonWithTitle:NSLocalizedString(@"str_go_setting", nil) block:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto://"] options:nil completionHandler:nil];
        }];
        [alertView addCancelButtonWithTitle:NSLocalizedString(@"str_not_now", nil) block:nil];
        [alertView show];
        return;
    }
    
    [self sendEmailAction];
}

- (void)clickRateUs {
    [SKStoreReviewController requestReview];
}

- (void)clickAbout {
    HZAppAboutViewController *vc = [[HZAppAboutViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - feedback
- (BOOL)checkEmailEnable {
    BOOL canSend = [MFMailComposeViewController canSendMail];
    return canSend;
}

- (void)sendEmailAction
{
    // 邮件服务器
    MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
    // 设置邮件代理
    [mailCompose setMailComposeDelegate:self];
    // 设置邮件主题
    [mailCompose setSubject:@"PDF Converter for iOS Feedback"];
    // 设置收件人
    [mailCompose setToRecipients:@[@"shamble.feedback@gmail.com"]];
    /**
    *  设置邮件的正文内容
    */
    NSString *sysVersion = [[UIDevice currentDevice] systemVersion];
    NSString *deviceNadme = [UIDevice currentDevice].machineModel;
    NSString *appVersion = [ [[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    CGFloat diskSpaceUsed = [UIDevice currentDevice].diskSpaceUsed * 1.0 / 1000000000.0;
    CGFloat diskSpaceFree = [UIDevice currentDevice].diskSpaceFree * 1.0 / 1000000000.0;
    
    NSString *string1 = [NSString stringWithFormat:@"Have problems to report(%@)",appVersion];
    NSString *string2 = [NSString stringWithFormat:@"Device Model: %@",deviceNadme];
    NSString *string3 = [NSString stringWithFormat:@"OS Version: %@",sysVersion];
    NSString *string4 = [NSString stringWithFormat:@"Free Capacity: %.2f GB / %.2f GB",diskSpaceUsed,diskSpaceFree];
    NSString *emailContent = [NSString stringWithFormat:@"%@\n\n%@\n%@\n%@",string1,string2,string3,string4];
    // 是否为HTML格式
    [mailCompose setMessageBody:emailContent isHTML:NO];
    // 弹出邮件发送视图
    [self presentViewController:mailCompose animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
      didFinishWithResult:(MFMailComposeResult)result
            error:(NSError *)error
{
  switch (result)
  {
    case MFMailComposeResultCancelled: // 用户取消编辑
      NSLog(@"Mail send canceled...");
      break;
    case MFMailComposeResultSaved: // 用户保存邮件
      NSLog(@"Mail saved...");
      break;
    case MFMailComposeResultSent: // 用户点击发送
      NSLog(@"Mail sent...");
      break;
    case MFMailComposeResultFailed: // 用户尝试保存或发送邮件失败
      NSLog(@"Mail send errored: %@...", [error localizedDescription]);
      break;
  }
  // 关闭邮件发送视图
  [self dismissViewControllerAnimated:YES completion:nil];
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
