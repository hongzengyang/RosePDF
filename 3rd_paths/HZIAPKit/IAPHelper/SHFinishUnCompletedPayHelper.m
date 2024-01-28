//
//  SHFinishUnCompletedPayHelper.m
//  PayHelper
//
//  Created by qiuludan on 2019/9/4.
//

#import "SHFinishUnCompletedPayHelper.h"

@interface SHFinishUnCompletedPayHelper ()

@property(nonatomic,copy) SHPayFinishCompletion finishCompletion;

@property(nonatomic,assign) NSInteger totalCount;

@property(nonatomic,strong) NSMutableArray <SKPaymentTransaction *>*unCompletedTrans;

@property(nonatomic,strong) NSMutableArray *removeTransactions;

@end

@implementation SHFinishUnCompletedPayHelper

- (void)finishUnCompletedTransactionsWithCompletion:(SHPayFinishCompletion)completion
{
    NSLog(@">>>> Pay: finish uncompleted trans -");
    
//    [_unCompletedTrans removeAllObjects];
//    [_removeTransactions removeAllObjects];
    
    //https://stackoverflow.com/questions/39800390/ios-in-app-purchases-handling-when-app-goes-to-background-unfinished-interrupte
    _finishCompletion = completion;
    
    //延迟执行这个方法的原因是：1.自动续订成功时，客户端本身并没有保存未完成订单（_storedUnfinishedOrders == 0），此时也要等待回调，把对应的transaction结束掉，然后析构对象；2.正常情况下，没有未完成订单，也要回调以析构对象。
    [self performSelector:@selector(noTransactionToBeRestoreHandler) withObject:nil afterDelay:5.0];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _unCompletedTrans = [[NSMutableArray alloc] init];
        _removeTransactions = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@">>>> Pay: SHFinishUnCompletedPayHelper dealloc! -");
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
            case SKPaymentTransactionStatePurchased:
            {
                [_unCompletedTrans addObject:transaction];
            }
                break;
            case SKPaymentTransactionStateFailed:
            case SKPaymentTransactionStateRestored:
            {
                // 直接finish恢复的
                [self finishTransaction:transaction];
            }
                break;
            default:
            {
                NSLog(@">>>> Pay: finish uncompleted payment with a non-usefull state : %ld -",transaction.transactionState);
            }
                break;
        }
    }
}

- (void)finishUpdateTranscations
{
    [self handleAllRestoreCompletedTransactions];
}

- (void)removedTransactions:(NSArray *)transactions
{
    //remove the duplicate trans
    [_removeTransactions removeObjectsInArray:transactions];
    [_removeTransactions addObjectsFromArray:transactions];
    
    if (_removeTransactions.count >= _unCompletedTrans.count)
    {
        if(_finishCompletion)
        {
            _finishCompletion(nil,YES, nil);
        }
    }
}

-(void)handleAllRestoreCompletedTransactions
{
    if (_finishCompletion)
    {
        _finishCompletion(nil, NO, _unCompletedTrans);
    }
}

- (void)finishUnCompletedTransIDs:(NSArray <NSString *>*)transIDs
{
    typeof(self) __weak weakSelf = self;
    [transIDs enumerateObjectsUsingBlock:^(NSString * _Nonnull transId, NSUInteger idx, BOOL * _Nonnull stop) {
        __block SKPaymentTransaction *payTrans = nil;
        [weakSelf.unCompletedTrans enumerateObjectsUsingBlock:^(SKPaymentTransaction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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

- (void)finishUnCompletedTransactions
{
    [self finishTransactions:_unCompletedTrans];
}

#pragma mark -

- (void)noTransactionToBeRestoreHandler
{
    if (_finishCompletion)
    {
        _finishCompletion(nil, NO, nil);
    }
}

@end
