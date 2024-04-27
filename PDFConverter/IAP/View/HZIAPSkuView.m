//
//  HZIAPSkuView.m
//  PDFConverter
//
//  Created by THS on 2024/4/25.
//

#import "HZIAPSkuView.h"
#import "HZCommonHeader.h"
#import "HZIAPManager.h"

@interface HZIAPSkuView()

@property (nonatomic, strong) UIImageView *selectImageView;

@property (nonatomic, strong) UILabel *priceLab;
@property (nonatomic, strong) UILabel *subPriceLab;
@property (nonatomic, strong) UILabel *tipLab;

@property (nonatomic, copy) void(^clickBlock)(void);


@end

@implementation HZIAPSkuView
- (instancetype)initWithFrame:(CGRect)frame skuId:(NSString *)skuId clickBlock:(void (^)(void))clickBlock {
    if (self = [super initWithFrame:frame]) {
        self.skuId = skuId;
        self.clickBlock = clickBlock;
        [self configView];
    }
    return self;
}

- (void)configView {
    self.layer.cornerRadius = 16;
    self.layer.masksToBounds = YES;
    
    self.selectImageView = [[UIImageView alloc] init];
    [self addSubview:self.selectImageView];
    [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(12);
        make.width.height.mas_equalTo(22);
        make.centerY.equalTo(self);
    }];
    
    UILabel *priceLab = [[UILabel alloc] init];
    self.priceLab = priceLab;
    [self addSubview:priceLab];
    priceLab.textColor = hz_getColor(@"000000");
    priceLab.font = [UIFont systemFontOfSize:16];
    
    UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self addSubview:btn];
    [btn addTarget:self action:@selector(clickButton) forControlEvents:(UIControlEventTouchUpInside)];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    if ([self.skuId isEqualToString:sku_weekly]) {
        self.priceLab.text = [NSString stringWithFormat:NSLocalizedString(@"str_price_week", nil),@"$4.99"];
        [self.priceLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.selectImageView.mas_trailing).offset(15);
            make.centerY.equalTo(self);
        }];
    }else if ([self.skuId isEqualToString:sku_yearly]) {
        self.priceLab.text = [NSString stringWithFormat:NSLocalizedString(@"str_price_year", nil),@"$24.99"];
        [self.priceLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.selectImageView.mas_trailing).offset(15);
            make.top.equalTo(self.selectImageView).offset(-5);
        }];
        
        //subPrice
        UILabel *subPriceLab = [[UILabel alloc] init];
        self.subPriceLab = subPriceLab;
        [self addSubview:subPriceLab];
        subPriceLab.textColor = hz_getColor(@"404040");
        subPriceLab.font = [UIFont systemFontOfSize:12 weight:(UIFontWeightMedium)];
        
        NSString *perWeekPrice = [NSString stringWithFormat:@"%@%@",@"$",@(0.48)];
        subPriceLab.text = [NSString stringWithFormat:@"≈ %@",[NSString stringWithFormat:NSLocalizedString(@"str_price_week", nil),perWeekPrice]];
        [subPriceLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.priceLab.mas_trailing).offset(3);
            make.centerY.equalTo(self.priceLab);
        }];
        
        UILabel *tipLab = [[UILabel alloc] init];
        self.tipLab = tipLab;
        tipLab.hidden = YES;
        [self addSubview:tipLab];
        tipLab.font = [UIFont systemFontOfSize:10 weight:(UIFontWeightMedium)];
        NSString *tipText = [NSString stringWithFormat:NSLocalizedString(@"str_freetrial_desc1", nil),@(3)];
        tipLab.text = tipText;
        [tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.priceLab);
            make.top.equalTo(self.priceLab.mas_bottom).offset(3);
        }];
        
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}

- (void)updateWithProduct:(SKProduct *)product {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:product.price];
    if ([formattedString hasSuffix:@".00"]) {
        formattedString = [formattedString stringByReplacingOccurrencesOfString:@".00" withString:@""];
    }
    
    //////////////////////////////////////
    
    if ([self.skuId isEqualToString:sku_weekly]) {
        self.priceLab.text = [NSString stringWithFormat:NSLocalizedString(@"str_price_week", nil),formattedString];
    }else if ([self.skuId isEqualToString:sku_yearly]) {
        self.priceLab.text = [NSString stringWithFormat:NSLocalizedString(@"str_price_year", nil),formattedString];
        
        NSString *perWeekPrice = [NSString stringWithFormat:@"%@%@",[product.priceLocale objectForKey:NSLocaleCurrencySymbol],[NSString stringWithFormat:@"%.2f",([product.price floatValue] / 52.0)]];
        self.subPriceLab.text = [NSString stringWithFormat:@"≈ %@",[NSString stringWithFormat:NSLocalizedString(@"str_price_week", nil),perWeekPrice]];
        
        NSString *tipText;
        {
            SKProductDiscount *discount = product.introductoryPrice;
            SKProductSubscriptionPeriod *period = discount.subscriptionPeriod;
            if (period.unit == SKProductPeriodUnitDay) {
                tipText = [NSString stringWithFormat:NSLocalizedString(@"str_freetrial_desc1", nil),@(period.numberOfUnits)];
            }else if (period.unit == SKProductPeriodUnitWeek) {
                tipText = [NSString stringWithFormat:NSLocalizedString(@"str_freetrial_desc1", nil),@(period.numberOfUnits * 7)];
            }
        }
        self.tipLab.text = tipText;
        self.tipLab.hidden = NO;
        
        [self setNeedsLayout];
        [self layoutIfNeeded];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[(id)hz_getColor(@"FF2424").CGColor, (id)hz_getColor(@"C403E3").CGColor];
        //gradientLayer.locations = @[@0, @0.5, @1];// 默认就是均匀分布
        gradientLayer.startPoint = CGPointMake(0, 0.5);
        gradientLayer.endPoint = CGPointMake(1, 0.5);
        gradientLayer.frame = self.tipLab.frame;
        gradientLayer.mask = self.tipLab.layer;
        self.tipLab.layer.frame = gradientLayer.bounds;
        [self.layer addSublayer:gradientLayer];
        
        UIImageView *discountImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rose_iap_discount_bg"]];
        discountImageView.contentMode = UIViewContentModeCenter;
        discountImageView.hidden = YES;
        [discountImageView sizeToFit];
        [self addSubview:discountImageView];
        [discountImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(47);
            make.height.mas_equalTo(38);
            make.centerY.equalTo(self);
            make.trailing.equalTo(self).offset(-4);
        }];
        
        UILabel *discountLab = [[UILabel alloc] init];
        discountLab.numberOfLines = 0;
        discountLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:discountLab];
        discountLab.font = [UIFont systemFontOfSize:10 weight:(UIFontWeightBold)];
        discountLab.textColor = [UIColor whiteColor];
        [discountLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(discountImageView);
        }];
        
        @weakify(self);
        [IAPInstance requestSku:@[sku_weekly] completeBlock:^(NSError *error, NSArray<SKProduct *> *products) {
            @strongify(self);
            if (error || products.count == 0) {
                return;
            }
            discountImageView.hidden = NO;
            SKProduct *weekProduct = [products firstObject];
            CGFloat weekPrice = [weekProduct.price floatValue];
            CGFloat yearPrice = [product.price floatValue];
            NSInteger percent = (weekPrice * 52.0 - yearPrice) / (weekPrice * 52.0) * 100;
            discountLab.text = [NSString stringWithFormat:NSLocalizedString(@"str_discount", nil),[NSString stringWithFormat:@"%ld%%",(long)percent]];
        }];
    }
}

- (void)configSelected:(BOOL)selected {
    if (selected) {
        self.backgroundColor = hz_getColorWithAlpha(@"2B96FA", 0.1);
        self.selectImageView.image = [UIImage imageNamed:@"rose_iap_select_s"];
    }else {
        self.backgroundColor = [UIColor clearColor];
        self.selectImageView.image = [UIImage imageNamed:@"rose_iap_select_n"];
    }
}

- (void)clickButton {
    if (self.clickBlock) {
        self.clickBlock();
    }
}

@end
