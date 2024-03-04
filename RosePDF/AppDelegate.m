//
//  AppDelegate.m
//  RosePDF
//
//  Created by THS on 2024/1/22.
//

#import "AppDelegate.h"
#import "HZHomeViewController.h"
#import "HZNavigationController.h"
#import <HZUIKit/HZUIKit.h>
#import "HZCommonHeader.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    if (isRTL) {
        [UIView appearance].semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        [UISearchBar appearance].semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self configProgressHUD];
    [self enterHome];
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
- (void)enterHome {
    HZHomeViewController *vc = [[HZHomeViewController alloc] init];
    HZNavigationController *nav = [[HZNavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [self.window setRootViewController:nav];
}


@end
