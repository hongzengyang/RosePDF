//
//  SHPayHelper.m
//  batchat
//
//  Created by qiuludan on 2019/8/6.
//  Copyright © 2019年 Crait. All rights reserved.
//

#import "SHPayHelper.h"
#import <HZFoundationKit/HZFoundationKit.h>

typedef void(^SHPayInfoRequestCompletion)(NSError *error, id params);


@interface SHPayHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, strong) NSArray *productInfos;
@property (nonatomic, copy) NSString *productID;

@property (nonatomic, copy) SHPayInfoRequestCompletion infoCompletion;
@property (nonatomic, copy) SHPayResultCompletion payCompletion;

@property(nonatomic,strong) SKPaymentTransaction *everPayButNotFinishedTransaction;
@property(nonatomic,strong) SKPaymentTransaction *payTranscation;

@property(nonatomic,assign) BOOL newPayment;

@end

@implementation SHPayHelper

- (instancetype)initWithProductID:(NSString *)productID
{
    if (![NSString hz_isEmpty:productID])
    {
        self = [super init];
        if (self)
        {
            _productID = productID;
        }
        return self;
    }
    return nil;
}

- (void)dealloc
{
    NSLog(@">>>> Pay: SHPayHelper dealloc! -");
}

#pragma mark -

- (void)requestProductsWithCompletion:(void(^)(NSError *error, NSArray *params))completion
{
    [self requestProductsDetails:@[_productID] completion:completion];
}

#pragma mark -
- (void)requestProductsDetails:(NSArray <NSString *>*)productIDs completion:(SHPayInfoRequestCompletion)completion
{
    if ([self canMakePayments])
    {
        if (productIDs.count > 0)
        {
            _infoCompletion = completion;
            
            NSSet *nsset = [NSSet setWithArray:productIDs];
            SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
            request.delegate = self;
            [request start];
        }
        else
        {
            if (completion)
            {
                NSString *message = [@"Empty product id list." stringByAppendingString:@"(12)"];
                NSError *error = [NSError hz_errorWithMessage:message code:SHPAY_EMPTY_PRODUCT_CODE];
                completion(error,nil);
            }
        }
    }
    else
    {
        if (completion)
        {
            NSError *error = [NSError hz_errorWithMessage:@"pay not_ support in this device(11)" code:SHPAY_NO_SUPPORT_PAY_CODE];
            completion(error,nil);
        }
    }
}

- (BOOL)canMakePayments
{
    return [SKPaymentQueue canMakePayments];
}

// Delegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@">>>> Pay: products info from apple -");
    NSArray *product = response.products;

    NSError *error = [NSError hz_errorWithMessage:@"pay restore not get order(13)" code:SHPAY_GET_PRODUCT_INFO_CODE];
    
    if(product.count > 0)
    {
        NSMutableArray *productsArray = [[NSMutableArray alloc] init];
        
        [product enumerateObjectsUsingBlock:^(SKProduct *pro, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSLog(@">>>> Pay: products descrip:%@, localTitle:%@, localDescrip:%@, price:%@, pID:%@", [pro description],[pro localizedTitle],[pro localizedDescription],[pro price],[pro productIdentifier]);
            [productsArray addObject:pro];
        }];
        
        if (_infoCompletion)
        {
            if (productsArray.count > 0)
            {
                _infoCompletion(nil,productsArray);
            }
            else
            {
                _infoCompletion(error,nil);
            }
        }
    }
    else
    {
        NSLog(@">>>> Pay: no product -");
        if (_infoCompletion)
        {
            _infoCompletion(error,nil);
        }
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    if (_infoCompletion)
    {
        _infoCompletion(error,nil);
    }
    NSLog(@">>>> Pay: reqeust product error : %@ -", error);
}

- (void)requestDidFinish:(SKRequest *)request
{
    NSLog(@">>>> Pay: reqeust product finished -");
}

#pragma mark -
- (void)buyProducts:(NSArray <SKProduct *>*)products completion:(SHPayResultCompletion)completion
{
    NSLog(@">>>> Pay: buy products -");
    self.productInfos = products;
    
    if (self.everPayButNotFinishedTransaction)
    {
        NSLog(@">>>> Pay: unfinished transaction exist, valiad it ： %@ -",self.everPayButNotFinishedTransaction.transactionIdentifier);
        if (completion)
        {
            completion(nil, self.everPayButNotFinishedTransaction);
        }
    }
    else
    {
        @synchronized(self)
        {
            self.newPayment = YES;
            self.payTranscation = nil;
        }
        
        self.payCompletion = completion;
        if (![self buyProducts:products username:self.userName])
        {
            NSLog(@">>>> Pay: empty products! -");
            self.payCompletion = nil;
            if (completion)
            {
                NSError *error = [NSError hz_errorWithMessage:@"Empty order ID(14)" code:SHPAY_BUY_EMPTY_PRODUCT_CODE];
                completion(error,nil);
            }
        }
    }
}

- (BOOL)buyProducts:(NSArray<SKProduct *> *)products username:(NSString *)username
{
    if (products.count > 0)
    {
        for (SKProduct *productItem in products)
        {
            if ([productItem isKindOfClass:[SKProduct class]])
            {
                SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:productItem];
                payment.applicationUsername = username;
                NSLog(@">>>> Pay: add payment request for %@ ,username = %@ -",productItem.productIdentifier, username);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[SKPaymentQueue defaultQueue] addPayment:payment];
                });
            }
        }
        return YES;
    }
    return NO;
}

// Delegate 子类
- (void)updatedPayTransactionCallBack:(SKPaymentTransaction *)transaction totalTransactionCount:(NSInteger)totalTransactionCount currentTransactionIndex:(NSInteger)currentTransactionIndex
{
    if ([transaction.payment.productIdentifier isEqualToString:_productID])
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
            {
                if (self.newPayment)
                {
                    self.payTranscation = transaction;
                }
                else
                {
                    @synchronized(self)
                    {
                        self.everPayButNotFinishedTransaction = transaction;
                    }
                }
            }
                break;
            case SKPaymentTransactionStateFailed:
            {
                self.payTranscation = transaction;
            }
                break;
            default:
            {
                NSLog(@">>>> Pay: make a payment with a non-usefull state : %ld -",transaction.transactionState);
            }
                break;
        }
    }
}

- (void)failPaymentWithTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@">>>> Pay: payment failed : %@ -",transaction.error.localizedDescription);
    NSString *message = (transaction.error.localizedDescription?transaction.error.localizedDescription:@"pay failed");
    NSError *error = [NSError hz_errorWithMessage:message code:transaction.error.code];
    
    if (self.payCompletion)
    {
        self.payCompletion(error, transaction);
    }
}

- (void)finishUpdateTranscations
{
    if (self.payTranscation)
    {
        if (self.payTranscation.transactionState == SKPaymentTransactionStatePurchased)
        {
            if (self.payCompletion)
            {
                self.payCompletion(nil, self.payTranscation);
            }
        }
        else if (self.payTranscation.transactionState == SKPaymentTransactionStateFailed)
        {
            [self failPaymentWithTransaction:self.payTranscation];
        }
    }
}
#pragma mark -

- (NSDictionary *)getProductInfoFromTransaction:(SKPaymentTransaction *)transaction
{
    if ([transaction isKindOfClass:[SKPaymentTransaction class]])
    {
        __block SKProduct *product = nil;
        
        [_productInfos enumerateObjectsUsingBlock:^(SKProduct *pro, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([pro.productIdentifier isEqualToString:transaction.payment.productIdentifier])
            {
                product = pro;
                *stop = YES;
            }
        }];
        
        if (product)
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            [dict setObject:([product localizedTitle]?[product localizedTitle]:@"") forKey:@"product_name"];
            [dict setObject:@"iOS IAP" forKey:@"pay_method"];
            [dict setObject:([product.priceLocale objectForKey:NSLocaleCurrencySymbol]?[product.priceLocale objectForKey:NSLocaleCurrencySymbol]:@"") forKey:@"price_quality"];
            [dict setObject:([product price]?[product price]:@(0)) forKey:@"price"];
            return @{@"product_info":dict};
        }
    }
    return nil;
}
@end
