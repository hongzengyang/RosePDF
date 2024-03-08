//
//  HZCameraUtils.m
//  HZAssetsPicker
//
//  Created by THS on 2024/3/5.
//

#import "HZCameraUtils.h"
#import <AVFoundation/AVFoundation.h>

@implementation HZCameraUtils

+ (void)checkCameraPermissionWithViewController:(UIViewController *)viewController completeBlock:(void(^)(BOOL complete))completeBlock {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"str_camera_permission_deny_title", nil) message:NSLocalizedString(@"str_camera_permission_deny_tip", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *done = [UIAlertAction actionWithTitle:NSLocalizedString(@"str_go_setting", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url options:@{UIApplicationOpenSettingsURLString:@YES} completionHandler:nil];
            }
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"str_cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVC addAction:done];
        [alertVC addAction:cancel];
        [viewController presentViewController:alertVC animated:NO completion:^{
        }];
        if (completeBlock) {
            completeBlock(NO);
        }
    }else if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (completeBlock) {
                    completeBlock(granted);
                }
            });
        }];
    }else {
        if (completeBlock) {
            completeBlock(YES);
        }
    }
}


@end
