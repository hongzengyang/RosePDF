//
//  SHBasePayHelper.h
//  hxtalk
//
//  Created by qiuludan on 2019/8/6.
//  Copyright © 2019年 Crait. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoreKit/StoreKit.h"

NS_ASSUME_NONNULL_BEGIN

#define SHPAYMENT_ERROR_DOMAIN @"SHPaymentErrorDomain"
#define SHPAYMENT_CLOSE_ORDER_ERROR_CODE -16

#define SHPAY_GET_ORDID_CODE -20  // 获取订单号order_id 失败
#define SHPAY_GET_PRODUCT_INFO_CODE -21 // 向apple服务器获取商品详情失败
#define SHPAY_NO_SUPPORT_PAY_CODE -22 // 设备不支持支付
#define SHPAY_EMPTY_PRODUCT_CODE -23 // 商品为空
#define SHPAY_BUY_EMPTY_PRODUCT_CODE -24 // 添加账单时商品为空失败
#define SHPAY_EMPTY_TRANSACTION_CODE -25 // apple订单为空
#define SHPAY_ERROR_RECIEPTDATA_CODE -26 // 验证前receiptdata错误
#define SHPAY_ERROR_VERIFY_PARAM_CODE -27 // 验证信息拼装错误
#define SHPAY_REMOTE_VERIFY_FAIL_CODE -28 // 服务端验证订单返回status=1
#define SHPAY_REMOTE_NO_MATCH_ORDER_CODE -29 // 服务端验证订单后返回的list里没有匹配到当前的订单


@interface SHBasePayHelper : NSObject

@property (nonatomic, copy) NSString *userName;

- (void)restoreCompletedTransactions;

// 结束订单
- (void)finishTransaction:(SKPaymentTransaction *)transaction;
- (void)finishTransactions:(NSArray <SKPaymentTransaction *>*)transactions;

#pragma mark - 子类
- (void)updatedPayTransactionCallBack:(SKPaymentTransaction * _Nullable)transaction totalTransactionCount:(NSInteger)totalTransactionCount currentTransactionIndex:(NSInteger)currentTransactionIndex;

- (void)removedTransactions:(NSArray *)transactions;



@end

NS_ASSUME_NONNULL_END
