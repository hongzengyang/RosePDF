//
//  HZIAPManager.m
//  batchat
//
//  Created by qiuludan on 2019/8/6.
//  Copyright © 2019年 Crait. All rights reserved.
//

#import "HZIAPManager.h"
#import <HZIAPKit/SHPayHelper.h>
#import <HZIAPKit/SHRestorePayHelper.h>
#import <HZIAPKit/SHFinishUnCompletedPayHelper.h>
#import <HZFoundationKit/HZFoundationKit.h>
#import <YYModel/NSObject+YYModel.h>

#define IAP_ORDER_KEY @"iap_order_key"

#define VERIFY_RECEIPT_SUCCESS_CODE 0
#define VERIFY_RECEIPT_APPPLE_SERVER_FAIL_CODE 21005
#define VERIFY_RECEIPT_APPPLE_FAIL_START_CODE 21000
#define VERIFY_RECEIPT_REPEAT_PAYMENT_CODE 30004

typedef NS_ENUM(NSInteger, SHPayVerifyAction)
{
    SHPayVerifyActionNormal = 1, // 普通验证
    SHPayVerifyActionRestore = 2, // 恢复验证
    SHPayVerifyActionRenewal = 3, // 自动续订验证
};

@interface HZIAPManager ()

@property (nonatomic, copy) NSString *appName;


@property (nonatomic, strong) SHPayHelper *payHelper;
@property (nonatomic, strong) SHRestorePayHelper *restoreHelper;
@property (nonatomic, strong) SHFinishUnCompletedPayHelper *finishHelper;

@property (nonatomic, copy) NSString *orderID;
@property (nonatomic, copy) NSString *productID;
@property (nonatomic, strong) NSMutableArray <NSDictionary *>*storedUnfinishedOrders;

@end


@implementation HZIAPManager

static HZIAPManager *sharedInstance = nil;
static dispatch_once_t onceToken;

+ (instancetype)sharedInstance {
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HZIAPManager alloc] init];
    });
    
    return sharedInstance;
}

- (void)configWithParams:(NSDictionary *)params {
    self.appName = [params valueForKey:@"appName"];
}

#pragma mark -

- (BOOL)startInAppPurchaseWithProduct:(NSString *)product completion:(void(^)(NSError * _Nullable error, id _Nullable params))completion {
    if (_payHelper) {
        if (completion) {
            completion([NSError hz_errorWithMessage:@"a running payment exist(1)"], nil);
        }
        return NO;
    }
    
    _payHelper = [[SHPayHelper alloc] initWithProductID:product];
    _payHelper.userName = self.appName;
    self.productID = product;
    __weak __typeof(self) weakSelf = self;
    // 获取applestore里产品信息以及购买
    [weakSelf requestProductsAndPayWithCompletion:^(NSError *error, id params) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (completion) {
            completion(error, params);
        }
        
        [strongSelf releasePayHelper];
    }];
    return YES;
}

- (void)requestProductsAndPayWithCompletion:(void(^)(NSError *error, id params))completion {
    typeof(self) __weak weakSelf = self;
    // 获取applestore里产品信息
    [self.payHelper requestProductsWithCompletion:^(NSError * _Nonnull error, NSArray * _Nonnull params) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            if (completion) {
                completion(error, nil);
            }
        }else {
            // 购买
            [weakSelf.payHelper buyProducts:params completion:^(NSError * _Nonnull error, SKPaymentTransaction * _Nonnull transaction) {
                if (error) {
                    [strongSelf.payHelper finishTransaction:transaction];
                    if (completion) {
                        completion(error, nil);
                    }
                }else {
                    // 购买完成后，验证凭证
//                    [strongSelf verifyTransaction:transaction orderID:orderID completion:^(NSError *error, id _Nullable params) {
//                    }];
                    if (completion) {
                        completion(error, [strongSelf.payHelper getProductInfoFromTransaction:transaction]);
                    }
                }
            }];
        }
    }];
}

#pragma mark -
- (void)finishUnCompletedTransactions
{
    if (_finishHelper)
    {
        NSLog(@">>>> Pay: there has another finish action in processing. -");
        return;
    }
    
    _finishHelper = [[SHFinishUnCompletedPayHelper alloc] init];
    _finishHelper.userName = self.appName;
    
    _storedUnfinishedOrders = [[NSMutableArray alloc] initWithArray:[HZIAPManager getStoredOrdersAtLocal]];
    
    __weak __typeof(self) weakSelf = self;
    // 向applestore恢复购买
    [_finishHelper finishUnCompletedTransactionsWithCompletion:^(NSError * _Nullable error, BOOL checkAuth, NSArray<SKPaymentTransaction *> * _Nullable unCompletedArray) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            NSLog(@">>>> Pay: finish failed : %@ -",error.localizedDescription);
        }else {
            if (unCompletedArray.count > 0) {
                __block NSMutableArray *orgArray = [NSMutableArray new];
                __block NSMutableArray *newArray = [NSMutableArray new];
                [unCompletedArray enumerateObjectsUsingBlock:^(SKPaymentTransaction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.originalTransaction){
                        // 续订
                        [orgArray addObject:obj];
                    }else{
                        // 第一次购买
                        [newArray addObject:obj];
                    }
                }];
                
                unCompletedArray = nil;
                NSData *receiptsData = [HZIAPManager getReceiptData];
                NSString *receiptStr = [receiptsData base64EncodedStringWithOptions:0];
                
                NSLog(@">>>> Pay: finish success with unCompletedArray:%@, receipt length:%lu -",unCompletedArray, (unsigned long)receiptStr.length);
                if (![NSString hz_isEmpty:receiptStr]) {
                    dispatch_group_t verifyPaymentGroup = dispatch_group_create();
                    dispatch_queue_t verifyPaymentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    
                    if (newArray.count > 0 && weakSelf.storedUnfinishedOrders.count > 0) {
                        dispatch_group_enter(verifyPaymentGroup);
                        dispatch_group_async(verifyPaymentGroup, verifyPaymentQueue, ^{
                            
                            [weakSelf verifyPaymentFromServerWithOrderList:weakSelf.storedUnfinishedOrders receiptStr:receiptStr action:SHPayVerifyActionNormal completion:^(NSError * _Nullable error, BOOL finishTranscations) {
                                if (finishTranscations)
                                {
                                    [strongSelf.finishHelper finishTransactions:newArray];
                                }
                                dispatch_group_leave(verifyPaymentGroup);
                            }];
                        });
                    }
                    
                    if (orgArray.count > 0) {
                        dispatch_group_enter(verifyPaymentGroup);
                        dispatch_group_async(verifyPaymentGroup, verifyPaymentQueue, ^{
                            
                            [weakSelf verifyPaymentFromServerWithTranscations:orgArray receiptStr:receiptStr action:SHPayVerifyActionRenewal completion:^(NSError * _Nullable error, BOOL finishTranscations) {
                                if (finishTranscations)
                                {
                                    [strongSelf.finishHelper finishTransactions:orgArray];
                                }
                                dispatch_group_leave(verifyPaymentGroup);
                            }];
                        });
                    }
                    
                    dispatch_group_notify(verifyPaymentGroup, dispatch_get_main_queue(), ^{
                        [weakSelf releaseFinishHelper];
                    });
                    return ;
                }
            }
            
            unCompletedArray = nil;
            [weakSelf.finishHelper finishUnCompletedTransactions];
        }
        [strongSelf releaseFinishHelper];
    }];
}

#pragma mark -
- (void)restoreCompletedTransactionsWithCompletion:(void(^)(NSError * _Nullable error, id _Nullable params))completion
{
    if (_restoreHelper) {
        NSLog(@">>>> Pay: there has another restore action in processing. -");
        if (completion) {
            completion([NSError hz_errorWithMessage:@"param error"], nil);
        }
        return;
    }
    
    _restoreHelper = [[SHRestorePayHelper alloc] init];
    _restoreHelper.userName = self.appName;
    
    __weak __typeof(self) weakSelf = self;
    [_restoreHelper restoreCompletedTransactionsWithCompletion:^(NSError * _Nullable error, NSArray<SKPaymentTransaction *> * _Nullable restoreTrans) {
        
        if (error) {
            if (completion){
                completion(error, nil);
            }
        }else {
            NSData *receiptsData = [HZIAPManager getReceiptData];
            NSString *receiptStr = [receiptsData base64EncodedStringWithOptions:0];
            if (restoreTrans.count > 0 && ![NSString hz_isEmpty:receiptStr]) {
                [weakSelf verifyPaymentFromServerWithTranscations:restoreTrans receiptStr:receiptStr action:SHPayVerifyActionRestore completion:^(NSError * _Nullable error, BOOL finishTranscations) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (finishTranscations) {
                        [strongSelf.restoreHelper finishRestoreTransactions];
                    }
                    
                    if (completion) {
                        completion(error, nil);
                    }
                    
                    [weakSelf releaseRestoreHelper];
                }];
                
                restoreTrans = nil;
                return;
            }
            else
            {
                if (completion)
                {
                    completion(nil, nil);
                }
            }
        }
        
        restoreTrans = nil;
        [weakSelf releaseRestoreHelper];
    }];
}

#pragma mark - Basic

- (void)verifyPaymentFromServerWithTranscations:(NSArray <SKPaymentTransaction *>*)trans receiptStr:(NSString *)receiptStr action:(NSInteger)action completion:(void(^)(NSError * _Nullable error, BOOL finishTranscations))completion
{
    NSDictionary *params = [HZIAPManager verifyParamWithTrans:trans receiptData:receiptStr action:action];
    if ([params isKindOfClass:[NSDictionary class]])
    {
        [self verifyPaymentFromServerWithParams:params action:action completion:completion];
    }
    else
    {
        if (completion)
        {
            NSError *error = [NSError hz_errorWithMessage:@"pay verify failed" code:SHPAY_ERROR_VERIFY_PARAM_CODE];
            completion(error, NO);
        }
    }
}

- (void)verifyPaymentFromServerWithOrderList:(NSArray <NSDictionary *>*)orderList receiptStr:(NSString *)receiptStr action:(NSInteger)action completion:(void(^)(NSError * _Nullable error, BOOL finishTranscations))completion
{
    NSDictionary *params = [HZIAPManager verifyParamWithOrderList:orderList receiptData:receiptStr action:action];
    if ([params isKindOfClass:[NSDictionary class]]) {
        if (orderList.count > 0) {
            [orderList enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [HZIAPManager addNewOrderAtLocal:obj];
            }];
        }
        
        [self verifyPaymentFromServerWithParams:params action:action completion:completion];
    }else {
        if (completion) {
            NSError *error = [NSError hz_errorWithMessage:@"pay verify failed(7)" code:SHPAY_ERROR_VERIFY_PARAM_CODE];
            completion(error, NO);
        }
    }
}

- (void)verifyPaymentFromServerWithParams:(NSDictionary *)params action:(NSInteger)action completion:(void(^)(NSError * _Nullable error, BOOL finishTranscations))completion {
    if (completion) {
        completion(nil, NO);
    }
}

#pragma mark -

-(void)releasePayHelper
{
    _payHelper = nil;
}

-(void)releaseRestoreHelper
{
    _restoreHelper = nil;
}

-(void)releaseFinishHelper
{
    _finishHelper = nil;
}

#pragma mark -

+ (NSDictionary *)verifyParamWithOrderList:(NSArray *)orderList receiptData:(NSString *)receiptData action:(NSInteger)action
{
    NSString *str = [orderList yy_modelToJSONString];
    return @{@"order_list":str,@"receipt_data":receiptData,@"pay_type":@(1),@"action":@(action)};
}

+ (NSDictionary *)verifyParamWithTrans:(NSArray <SKPaymentTransaction *>*)trans receiptData:(NSString *)receiptData action:(NSInteger)action
{
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    [trans enumerateObjectsUsingBlock:^(SKPaymentTransaction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dict =  @{@"trans_id":obj.transactionIdentifier,@"org_trans_id":obj.originalTransaction.transactionIdentifier?:@"",@"order_id":@""};
        [temp addObject:dict];
    }];
    NSString *str = [temp yy_modelToJSONString];
    return @{@"order_list":str,@"receipt_data":receiptData,@"pay_type":@(1),@"action":@(action)};
}

+ (BOOL)isFinishTranscationWithStatus:(NSInteger)status
{
    BOOL finish = NO;
    if (status > VERIFY_RECEIPT_APPPLE_FAIL_START_CODE)
    {
        if (status == VERIFY_RECEIPT_APPPLE_SERVER_FAIL_CODE)
        {
            finish = NO;
        }
        else if (status == VERIFY_RECEIPT_REPEAT_PAYMENT_CODE)
        {
            finish = YES;
        }
        else
        {
            finish = YES;
        }
    }
    return finish;
}

#pragma mark -

#pragma mark -

+ (NSData *)getReceiptData
{
    NSURL *recepitURL = [[NSBundle mainBundle] appStoreReceiptURL];
    return [NSData dataWithContentsOfURL:recepitURL];
}

+ (NSArray <NSDictionary *>*)getStoredOrdersAtLocal
{
    NSArray <NSDictionary *>*orders = (NSArray <NSDictionary *>*)[NSKeyedArchiver hz_objectForKey:IAP_ORDER_KEY];
    
    return orders;
}

+ (void)removeStoredOrders
{
    [NSKeyedArchiver hz_removeObjectForKey:IAP_ORDER_KEY];
}

+ (void)addNewOrderAtLocal:(NSDictionary *)order
{
    NSString *orderID = order[@"order_id"];
    if ([order isKindOfClass:[NSDictionary class]] && ![NSString hz_isEmpty:orderID])
    {
        NSMutableArray *existOrders = [[NSMutableArray alloc] initWithArray:[self getStoredOrdersAtLocal]];
        NSDictionary *obj = [self getTargetObjInArray:existOrders targetID:order[@"order_id"]];
        if (obj)
        {
            [existOrders removeObject:obj];
        }
        
        [existOrders addObject:order];
        [NSKeyedArchiver hz_setObject:existOrders forKey:IAP_ORDER_KEY];
    }
}

+ (void)removeVerifiedOrders:(NSArray <NSDictionary *>*)verifiedOrders
{
    if (verifiedOrders.count > 0)
    {
        NSMutableArray *targetObjs = [[NSMutableArray alloc] initWithCapacity:verifiedOrders.count];
        NSMutableArray *existOrders = [[NSMutableArray alloc] initWithArray:[self getStoredOrdersAtLocal]];
        
        [verifiedOrders enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull order, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *obj = [self getTargetObjInArray:existOrders targetID:order[@"order_id"]];
            if (obj)
            {
                [targetObjs addObject:obj];
            }
        }];
        
        [existOrders removeObjectsInArray:targetObjs];
        [NSKeyedArchiver hz_setObject:existOrders forKey:IAP_ORDER_KEY];
    }
}

+ (void)removeTargetOrder:(NSString *)order
{
    if (![NSString hz_isEmpty:order])
    {
        NSMutableArray *existOrders = [[NSMutableArray alloc] initWithArray:[self getStoredOrdersAtLocal]];
        NSDictionary *obj = [self getTargetObjInArray:existOrders targetID:order];
        if (obj)
        {
            [existOrders removeObject:obj];
        }
        
        [NSKeyedArchiver hz_setObject:existOrders forKey:IAP_ORDER_KEY];
    }
}

+ (NSDictionary *)getTargetObjInArray:(NSArray <NSDictionary *>*)array targetID:(NSString *)targetID
{
    __block NSDictionary *target = nil;
    [array enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSDictionary class]] && [obj[@"order_id"] isEqualToString:targetID])
        {
            target = obj;
            *stop = YES;
        }
    }];
    return target;
}


@end
