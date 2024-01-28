//
//  SHFinishUnCompletedPayHelper.h
//  PayHelper
//
//  Created by qiuludan on 2019/9/4.
//

#import "SHBasePayHelper.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^SHPayFinishCompletion)(NSError * _Nullable error, BOOL checkAuth, NSArray <SKPaymentTransaction *>* _Nullable unCompletedArray);

@interface SHFinishUnCompletedPayHelper : SHBasePayHelper

- (void)finishUnCompletedTransactionsWithCompletion:(SHPayFinishCompletion)completion;

- (void)finishUnCompletedTransIDs:(NSArray <NSString *>*)transIDs;

- (void)finishUnCompletedTransactions;

@end

NS_ASSUME_NONNULL_END
