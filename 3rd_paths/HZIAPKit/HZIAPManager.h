//
//  HZIAPManager.h
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HZIAPManager : NSObject

+ (instancetype)sharedInstance;

//appName:
- (void)configWithParams:(NSDictionary *)params;

/*
 * 支付订单接口
 *
 * @param product 产品id
 * @param verifyType 验证类型（0：不验证，1：验证）
 */
- (BOOL)startInAppPurchaseWithProduct:(NSString *)product completion:(void(^)(NSError * _Nullable error, id _Nullable params))completion;

/*
 * 完成未完整的订单
 */
- (void)finishUnCompletedTransactions;

/*
 * 恢复完成的购买
 */
- (void)restoreCompletedTransactionsWithCompletion:(void(^)(NSError * _Nullable error, id _Nullable params))completion;

@end

NS_ASSUME_NONNULL_END
