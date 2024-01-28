//
//  SHRestorePayHelper.m
//  batchat
//
//  Created by qiuludan on 2019/8/6.
//  Copyright © 2019年 Crait. All rights reserved.
//

#import "SHRestorePayHelper.h"


@interface SHRestorePayHelper () <SKPaymentTransactionObserver>

@property(nonatomic,assign) NSInteger totalCount;

@property(nonatomic,strong) NSMutableArray <SKPaymentTransaction *>*restoredTransactions;

@property(nonatomic,copy) SHPayRestoreCompletion restoreCompletion;

@end


@implementation SHRestorePayHelper

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _restoredTransactions = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@">>>> Pay: SHRestorePayHelper dealloc! -");
}

#pragma mark -
- (void)restoreCompletedTransactionsWithCompletion:(SHPayRestoreCompletion)completion
{
    NSLog(@">>>> Pay: restore completed trans -");
    
    [_restoredTransactions removeAllObjects];
    
    _restoreCompletion = completion;
    
    [self restoreCompletedTransactions];
}

// Delegate 子类
- (void)updatedPayTransactionCallBack:(SKPaymentTransaction *)transaction totalTransactionCount:(NSInteger)totalTransactionCount currentTransactionIndex:(NSInteger)currentTransactionIndex
{
    if (transaction)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(noTransactionToBeRestoreHandler) object:nil];
        
        _totalCount = totalTransactionCount;
        
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStateRestored:
            {
                [_restoredTransactions addObject:transaction];
            }
                break;
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateFailed:
            default:
            {
                NSLog(@">>>> Pay: restore a payment with a non-usefull state : %ld -",transaction.transactionState);
            }
                break;
        }
    }
}

- (void)finishRestoreTransIDs:(NSArray <NSString *>*)transIDs
{
    typeof(self) __weak weakSelf = self;
    [transIDs enumerateObjectsUsingBlock:^(NSString * _Nonnull transId, NSUInteger idx, BOOL * _Nonnull stop) {
        __block SKPaymentTransaction *payTrans = nil;
        [weakSelf.restoredTransactions enumerateObjectsUsingBlock:^(SKPaymentTransaction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.transactionIdentifier isEqualToString:transId])
            {
                payTrans = obj;
                *stop = YES;
            }
        }];

        if (payTrans)
        {
            [weakSelf finishTransaction:payTrans];
        }
    }];
}

- (void)finishRestoreTransactions
{
    [self finishTransactions:_restoredTransactions];
}

#pragma mark -
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@">>>> Pay: restore finish -");
    if (_restoreCompletion)
    {
        _restoreCompletion(nil, _restoredTransactions);
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@">>>> Pay: restore failed -");
    if (_restoreCompletion)
    {
        _restoreCompletion(error, nil);
    }
}
@end
