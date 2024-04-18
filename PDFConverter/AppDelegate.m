//
//  AppDelegate.m
//  RosePDF
//
//  Created by THS on 2024/1/22.
//

#import "AppDelegate.h"
#import "HZHomeViewController.h"
#import "HZUserGuideViewController.h"
#import "HZNavigationController.h"
#import <HZUIKit/HZUIKit.h>
#import "HZCommonHeader.h"
#import "HZIAPManager.h"
#import "HZIAPViewController.h"

@import FirebaseCore;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [FIRApp configure];
    
    if (isRTL) {
        [UIView appearance].semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        [UISearchBar appearance].semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    }
    
    [IAPInstance application:application didFinishLaunchingWithOptions:launchOptions];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self configProgressHUD];
    [self configViewController];
    [self requestNetworkPermission];
    return YES;
}

#pragma mark - Private
- (void)configProgressHUD {
    [SVProgressHUD setDefaultStyle:(SVProgressHUDStyleDark)];
    [SVProgressHUD setDefaultAnimationType:(SVProgressHUDAnimationTypeNative)];
    [SVProgressHUD setDefaultMaskType:(SVProgressHUDMaskTypeClear)];
    [SVProgressHUD setMinimumDismissTimeInterval:3];
    [SVProgressHUD setMaximumDismissTimeInterval:5];
}
- (void)configViewController {
    
    if ([HZUserGuideViewController checkDisplayed]) {
        HZHomeViewController *vc = [[HZHomeViewController alloc] init];
        HZNavigationController *nav = [[HZNavigationController alloc] initWithRootViewController:vc];
        nav.navigationBarHidden = YES;
        [self.window setRootViewController:nav];
    }else {
        HZUserGuideViewController *vc = [[HZUserGuideViewController alloc] init];
        HZNavigationController *nav = [[HZNavigationController alloc] initWithRootViewController:vc];
        nav.navigationBarHidden = YES;
        [self.window setRootViewController:nav];
        
        @weakify(self);
        @weakify(nav);
        vc.overBlock = ^{
            @strongify(self);
            @strongify(nav);
            HZIAPViewController *vc = [[HZIAPViewController alloc] init];
            [nav pushViewController:vc animated:YES];
            
            vc.clickCloseBlock = ^{
                @strongify(self);
                @strongify(nav);
                HZHomeViewController *homeVC = [[HZHomeViewController alloc] init];
                [nav pushViewController:homeVC animated:YES];
                nav.viewControllers = @[homeVC];
            };
            vc.successBlock = ^{
                @strongify(self);
                @strongify(nav);
                HZHomeViewController *homeVC = [[HZHomeViewController alloc] init];
                [nav pushViewController:homeVC animated:YES];
                nav.viewControllers = @[homeVC];
            };
        };
    }
}

- (void)requestNetworkPermission {
    // 检查是否已获得了网络权限
    NSURL *url = [NSURL URLWithString:@"https://www.example.com"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 如果发生错误或未授权，则触发网络权限弹窗
        if (error) {
            NSLog(@"请求网络权限失败: %@", error);
        }
    }];
    [task resume];
}

@end
