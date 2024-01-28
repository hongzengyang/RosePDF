//
//  SHRestorePayHelper.h
//  batchat
//
//  Created by qiuludan on 2019/8/6.
//  Copyright © 2019年 Crait. All rights reserved.
//

#import "SHBasePayHelper.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^SHPayRestoreCompletion)(NSError * _Nullable error, NSArray <SKPaymentTransaction *>* _Nullable restoreTrans);

@interface SHRestorePayHelper : SHBasePayHelper

- (void)restoreCompletedTransactionsWithCompletion:(SHPayRestoreCompletion)completion;

- (void)finishRestoreTransIDs:(NSArray <NSString *>*)transIDs;

- (void)finishRestoreTransactions;

@end

NS_ASSUME_NONNULL_END
