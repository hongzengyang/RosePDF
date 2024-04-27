//
//  HZIAPSkuView.h
//  PDFConverter
//
//  Created by THS on 2024/4/25.
//

#import <UIKit/UIKit.h>

@class SKProduct;

@interface HZIAPSkuView : UIView

@property (nonatomic, copy) NSString *skuId;

- (instancetype)initWithFrame:(CGRect)frame skuId:(NSString *)skuId clickBlock:(void(^)(void))clickBlock;

- (void)updateWithProduct:(SKProduct *)product;
- (void)configSelected:(BOOL)selected;

@end

