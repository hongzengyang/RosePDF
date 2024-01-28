//
//  SHPayHelper.h
//  batchat
//
//  Created by qiuludan on 2019/8/6.
//  Copyright © 2019年 Crait. All rights reserved.
//

#import "SHBasePayHelper.h"

NS_ASSUME_NONNULL_BEGIN

//@protocol SHPayDelegate <NSObject>
//
//- (void)finishRequestProducts:(NSArray *)products error:(NSError *)error;
//
//- (void)finishPaymentTransaction:(SKPaymentTransaction *)transcation;
//
//@end

typedef void(^SHPayResultCompletion)(NSError * _Nullable error, SKPaymentTransaction * _Nullable transaction);

@interface SHPayHelper : SHBasePayHelper

- (instancetype)initWithProductID:(NSString *)productID;

- (void)requestProductsWithCompletion:(void(^)(NSError *error, NSArray *params))completion;

- (void)buyProducts:(NSArray <SKProduct *>*)products completion:(SHPayResultCompletion)completion;

- (NSDictionary *)getProductInfoFromTransaction:(SKPaymentTransaction *)transaction;

@end

NS_ASSUME_NONNULL_END
