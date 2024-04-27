//
//  HZIAPManager.m
//  RosePDF
//
//  Created by THS on 2024/3/25.
//

#import "HZIAPManager.h"
#import <XYIAPKit/XYIAPKit.h>
#import <XYIAPKit/XYStoreiTunesReceiptVerifier.h>
#import <XYIAPKit/XYStoreUserDefaultsPersistence.h>

@interface HZIAPManager()<XYStoreObserver>

@end

@implementation HZIAPManager
+ (HZIAPManager *)manager {
    static dispatch_once_t pred;
    static HZIAPManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[HZIAPManager alloc] init];
    });
    return sharedInstance;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [XYStoreiTunesReceiptVerifier shareInstance].sharedSecretKey = @"e597afb4606e450993952a01e742119c";
    [[XYStore defaultStore] registerReceiptVerifier:[XYStoreiTunesReceiptVerifier shareInstance]];
    [[XYStore defaultStore] registerTransactionPersistor:[XYStoreUserDefaultsPersistence shareInstance]];
    [[XYStore defaultStore] addStoreObserver:self];
    return YES;
}

- (void)requestSku:(NSArray *)skus completeBlock:(void (^)(NSError *, NSArray<SKProduct *> *))completeBlock {
    [[XYStore defaultStore] requestProducts:[NSSet setWithArray:skus] success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completeBlock) {
                completeBlock(nil,products);
            }
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completeBlock) {
                completeBlock(error,nil);
            }
        });
    }];
}

- (void)purchaseSku:(NSString *)sku completeBlock:(void (^)(NSError *, SKPaymentTransaction *))completeBlock {
    [[XYStore defaultStore] addPayment:sku success:^(SKPaymentTransaction *transaction) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completeBlock) {
                completeBlock(nil,transaction);
            }
        });
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completeBlock) {
                completeBlock(error,transaction);
            }
        });
    }];
}

- (void)restoreWithCompleteBlock:(void (^)(BOOL))completeBlock {
    [[XYStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions) {
        NSLog(@"restore === %@", transactions);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completeBlock) {
                completeBlock(YES);
            }
        });
    } failure:^(NSError *error) {
        NSLog(@"restore error === %@", error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completeBlock) {
                completeBlock(NO);
            }
        });
    }];
}

- (BOOL)isVip {
    BOOL vip = NO;
    if ([[XYStoreiTunesReceiptVerifier shareInstance] isSubscribedWithAutoRenewProduct:sku_weekly]) {
        vip = YES;
    }
    if ([[XYStoreiTunesReceiptVerifier shareInstance] isSubscribedWithAutoRenewProduct:sku_yearly]) {
        vip = YES;
    }
    return vip;
}

#pragma mark - XYStoreObserver
- (void)storePaymentTransactionFinished:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_iap_changed object:nil];
    });
}

- (void)storeRestoreTransactionsFinished:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_iap_changed object:nil];
    });
}

@end
