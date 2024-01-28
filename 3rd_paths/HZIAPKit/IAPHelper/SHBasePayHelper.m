//
//  SHBasePayHelper.m
//  hxtalk
//
//  Created by qiuludan on 2019/8/6.
//  Copyright © 2019年 Crait. All rights reserved.
//

#import "SHBasePayHelper.h"

/* alert code 
 1: A running payment exist 有一个payhelper正在执行
 2: 服务端生成order_id的返回内容为空
 3: 服务端生成order_id 报错
 4: 服务端关闭order_id 报错
 5: 验证新购买订单时，receipt或者trans_id为空
 6: 验证新购买订单时，订单transcation为空
 7: 验证订单时，参数不正确
 8: 验证订单时，服务端报错
 9: 验证订单时，服务端返回status不等于0
 10: 验证结果中，verify_status中全部不等于0，没有验证成功
 11: 当前设备不支持IAP
 12: 请求product信息时，没有product_id
 13: product信息回调时，信息获取为空
 14: addPayment 失败
 15: 支付时order_id为空
 */

@interface SHBasePayHelper () <SKPaymentTransactionObserver>

@end

@implementation SHBasePayHelper

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // 设置购买队列的监听器
        if ([SKPaymentQueue defaultQueue])
        {
            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        }
    }
    return self;
}

- (void)restoreCompletedTransactions
{
    if ([SKPaymentQueue defaultQueue])
    {
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }
}

- (void)dealloc
{
    if ([SKPaymentQueue defaultQueue]) {
        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    }
    NSLog(@">>>> Pay: SHBasePayHelper dealloc! -");
}

// Delegate
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    if (transactions.count > 0)
    {
        for (SKPaymentTransaction *transaction in transactions)
        {
            NSLog(@">>>> Pay: product : %@ , state : %@ ,trans_id: %@  org_trans_id: %@  username:%@ -",transaction.payment.productIdentifier,@(transaction.transactionState),transaction.transactionIdentifier,transaction.originalTransaction.transactionIdentifier, transaction.payment.applicationUsername);
            [self updatedPayTransactionCallBack:transaction totalTransactionCount:transactions.count currentTransactionIndex:[transactions indexOfObject:transaction]];
        }
        
        if (self)
        {
            [self finishUpdateTranscations];
        }
    }
    else
    {
        [self updatedPayTransactionCallBack:nil totalTransactionCount:0 currentTransactionIndex:0];
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    [self removedTransactions:transactions];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"==== finished ======");
}

#pragma mark - 子类重写
- (void)updatedPayTransactionCallBack:(SKPaymentTransaction * _Nullable)transaction totalTransactionCount:(NSInteger)totalTransactionCount currentTransactionIndex:(NSInteger)currentTransactionIndex
{
    
}

- (void)removedTransactions:(NSArray *)transactions
{
    
}

- (void)finishUpdateTranscations
{
    
}

#pragma mark - Basic
- (void)finishTransaction:(SKPaymentTransaction *)transaction
{
    if ([transaction isKindOfClass:[SKPaymentTransaction class]])
    {
        NSLog(@">>>> Pay: finish trans_id = %@", transaction.transactionIdentifier);
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

- (void)finishTransactions:(NSArray <SKPaymentTransaction *>*)transactions
{
    [transactions enumerateObjectsUsingBlock:^(SKPaymentTransaction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self finishTransaction:obj];
    }];
}

@end
