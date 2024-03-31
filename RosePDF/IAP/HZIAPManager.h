//
//  HZIAPManager.h
//  RosePDF
//
//  Created by THS on 2024/3/25.
//

#import <Foundation/Foundation.h>
@import StoreKit;

#define IAPInstance  [HZIAPManager manager]

#define sku_weekly          @"pdfconverter.premium.weekly"

#define notify_iap_changed  @"notify_iap_changed"

@interface HZIAPManager : NSObject

+ (HZIAPManager *)manager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

- (void)requestSku:(NSArray *)skus completeBlock:(void(^)(NSError *error,NSArray <SKProduct *>*products))completeBlock;

- (void)purchaseSku:(NSString *)sku completeBlock:(void(^)(NSError *error,SKPaymentTransaction *transaction))completeBlock;

- (void)restoreWithCompleteBlock:(void(^)(BOOL suc))completeBlock;

- (BOOL)isVip;

@end
