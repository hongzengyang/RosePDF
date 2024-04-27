//
//  HZIAPDetainmentView.m
//  PDFConverter
//
//  Created by THS on 2024/4/24.
//

#import "HZIAPDetainmentView.h"
#import "HZCommonHeader.h"
#import "HZIAPManager.h"

@interface HZIAPDetainmentView()

@property (nonatomic, copy) void(^closeBlock)(void);
@property (nonatomic, copy) void(^buySuccessBlock)(void);


@property (nonatomic, strong) UIButton *purchaseBtn;
@property (nonatomic, strong) UILabel *tipLab;

@property (nonatomic, copy) NSString *detainmentIdentifier;


@end

@implementation HZIAPDetainmentView
- (instancetype)initWithFrame:(CGRect)frame closeBlock:(void(^)(void))closeBlock buySuccessBlock:(void(^)(void))buySuccessBlock; {
    if (self = [super initWithFrame:frame]) {
        self.closeBlock = closeBlock;
        self.buySuccessBlock = buySuccessBlock;
        self.detainmentIdentifier = sku_yearly;
        [self configView];
    }
    return self;
}

- (void)configView {
    self.backgroundColor = [UIColor whiteColor];
    
    NSString *imageName;
    if ([[HZSystemManager manager] iPadDevice]) {
        imageName = @"rose_detainment_bg_ipad";
    }else {
        imageName = @"rose_detainment_bg";
    }
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [bgImageView sizeToFit];
    [self addSubview:bgImageView];
    [bgImageView setFrame:CGRectMake(0, 0, ScreenWidth, ScreenWidth / (bgImageView.width/bgImageView.height))];
    
    UIButton *closeBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self addSubview:closeBtn];
    [closeBtn setImage:[UIImage imageNamed:@"rose_iap_close"] forState:(UIControlStateNormal)];
    [closeBtn addTarget:self action:@selector(clickCloseButton) forControlEvents:(UIControlEventTouchUpInside)];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(22);
        make.top.equalTo(self).offset(hz_safeTop);
        make.width.height.mas_equalTo(28);
    }];
    
    UIButton *purchaseBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.purchaseBtn = purchaseBtn;
    [self addSubview:purchaseBtn];
    purchaseBtn.layer.cornerRadius = 16;
    purchaseBtn.layer.masksToBounds = YES;
    [purchaseBtn setTitle:NSLocalizedString(@"str_start", nil) forState:(UIControlStateNormal)];
    purchaseBtn.titleLabel.font = [UIFont systemFontOfSize:17 weight:(UIFontWeightSemibold)];
    [purchaseBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [purchaseBtn addTarget:self action:@selector(clickPurchaseButton) forControlEvents:(UIControlEventTouchUpInside)];
    [purchaseBtn setFrame:CGRectMake((self.width - 254)/2.0, self.height - hz_safeBottom - 32 - 56, 254, 56)];
    [purchaseBtn hz_addGradientWithColors:@[hz_main_color,hz_getColor(@"83BAF2")] startPoint:CGPointMake(0, 0.5) endPoint:CGPointMake(1, 0.5)];
    
    self.tipLab = [[UILabel alloc] init];
    self.tipLab.numberOfLines = 0;
    self.tipLab.font = [UIFont systemFontOfSize:10];
    self.tipLab.textAlignment = NSTextAlignmentCenter;
    self.tipLab.textColor = hz_getColorWithAlpha(@"000000", 0.6);
    [self addSubview:self.tipLab];
    
    [self configMiddleView];
    
    [self requestDetainmentProduct];
}

- (void)configMiddleView {
    
    CGFloat space;
    if ([[HZSystemManager manager] iPadDevice]) {
        space = (ScreenWidth - 375)/2.0 + 21;
    }else {
        space = 43;
    }
    
    UIImageView *step3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rose_step3"]];
    {
        step3.backgroundColor = hz_1_bgColor;
        step3.contentMode = UIViewContentModeCenter;
        [self addSubview:step3];
        [step3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(36);
            make.leading.equalTo(self).offset(space);
            make.bottom.equalTo(self.purchaseBtn.mas_top).offset(-100);
        }];
        
        UILabel *label1 = [[UILabel alloc] init];
        [self addSubview:label1];
        label1.font = [UIFont systemFontOfSize:20 weight:(UIFontWeightMedium)];
        label1.textColor = hz_getColor(@"484850");
        label1.text = [NSString stringWithFormat:NSLocalizedString(@"str_freetrial_newuser_day", nil),@(3)];
        [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(step3.mas_trailing).offset(8);
            make.top.equalTo(step3);
        }];
        
        UILabel *label2 = [[UILabel alloc] init];
        [self addSubview:label2];
        label2.numberOfLines = 0;
        label2.font = [UIFont systemFontOfSize:12 weight:(UIFontWeightMedium)];
        label2.textColor = hz_getColorWithAlpha(@"484850", 0.5);
        label2.text = NSLocalizedString(@"str_freetrial_newuser_day3_desc", nil);
        [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(label1);
            make.trailing.equalTo(self).offset(-space);
            make.top.equalTo(label1.mas_bottom).offset(8);
        }];
    }
    
    UIView *connect23 = [[UIView alloc] init];
    connect23.backgroundColor = hz_1_bgColor;
    [self addSubview:connect23];
    [connect23 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(step3);
        make.bottom.equalTo(step3.mas_top).offset(-2);
        make.width.mas_equalTo(4);
        make.height.mas_equalTo(56);
    }];
    
    UIImageView *step2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rose_step2"]];
    {
        step2.backgroundColor = hz_1_bgColor;
        step2.contentMode = UIViewContentModeCenter;
        [self addSubview:step2];
        [step2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(36);
            make.leading.equalTo(self).offset(space);
            make.bottom.equalTo(connect23.mas_top).offset(-2);
        }];
        
        UILabel *label1 = [[UILabel alloc] init];
        [self addSubview:label1];
        label1.font = [UIFont systemFontOfSize:20 weight:(UIFontWeightMedium)];
        label1.textColor = hz_getColor(@"484850");
        label1.text = [NSString stringWithFormat:NSLocalizedString(@"str_freetrial_newuser_day", nil),@(2)];
        [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(step2.mas_trailing).offset(8);
            make.top.equalTo(step2);
        }];
        
        UILabel *label2 = [[UILabel alloc] init];
        [self addSubview:label2];
        label2.numberOfLines = 0;
        label2.font = [UIFont systemFontOfSize:12 weight:(UIFontWeightMedium)];
        label2.textColor = hz_getColorWithAlpha(@"484850", 0.5);
        label2.text = NSLocalizedString(@"str_freetrial_newuser_day2_desc", nil);
        [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(label1);
            make.trailing.equalTo(self).offset(-space);
            make.top.equalTo(label1.mas_bottom).offset(8);
        }];
    }
    
    UIView *connect12 = [[UIView alloc] init];
    connect12.backgroundColor = hz_1_bgColor;
    [self addSubview:connect12];
    [connect12 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(4);
        make.height.mas_equalTo(56);
        make.centerX.equalTo(step2);
        make.bottom.equalTo(step2.mas_top).offset(-2);
    }];
    
    UIImageView *step1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rose_step1"]];
    {
        step1.backgroundColor = hz_1_bgColor;
        step1.contentMode = UIViewContentModeCenter;
        [self addSubview:step1];
        [step1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(36);
            make.leading.equalTo(self).offset(space);
            make.bottom.equalTo(connect12.mas_top).offset(-2);
        }];
        
        UILabel *label1 = [[UILabel alloc] init];
        [self addSubview:label1];
        label1.font = [UIFont systemFontOfSize:20 weight:(UIFontWeightMedium)];
        label1.textColor = hz_getColor(@"484850");
        label1.text = [NSString stringWithFormat:NSLocalizedString(@"str_freetrial_newuser_day", nil),@(1)];
        [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(step1.mas_trailing).offset(8);
            make.top.equalTo(step1);
        }];
        
        UILabel *label2 = [[UILabel alloc] init];
        [self addSubview:label2];
        label2.numberOfLines = 0;
        label2.font = [UIFont systemFontOfSize:12 weight:(UIFontWeightMedium)];
        label2.textColor = hz_getColorWithAlpha(@"484850", 0.5);
        label2.text = NSLocalizedString(@"str_freetrial_newuser_today_desc", nil);
        [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(label1);
            make.trailing.equalTo(self).offset(-space);
            make.top.equalTo(label1.mas_bottom).offset(8);
        }];
    }
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.numberOfLines = 0;
    [self addSubview:titleLab];
    titleLab.text = [NSString stringWithFormat:@"%@\n%@",NSLocalizedString(@"str_freetrial_newuser_title1", nil),NSLocalizedString(@"str_freetrial_newuser_title2", nil)];
    titleLab.textColor = hz_getColor(@"484850");
    titleLab.font = [UIFont systemFontOfSize:29 weight:(UIFontWeightBold)];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(space);
        make.trailing.equalTo(self).offset(-space);
        make.bottom.equalTo(step1.mas_top).offset(-30);
    }];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    step1.layer.cornerRadius = step1.width/2.0;
    step1.layer.masksToBounds = YES;
    step2.layer.cornerRadius = step2.width/2.0;
    step2.layer.masksToBounds = YES;
    step3.layer.cornerRadius = step3.width/2.0;
    step3.layer.masksToBounds = YES;
    
    connect12.layer.cornerRadius = connect12.width/2.0;
    connect23.layer.cornerRadius = connect23.width/2.0;
}

- (void)requestDetainmentProduct {
    
    NSString *str1 = [NSString stringWithFormat:NSLocalizedString(@"str_freetrial_desc2", nil),@(3),@"$24.99"];
    NSString *str2 = NSLocalizedString(@"str_cancelanytime", nil);
    self.tipLab.text = [NSString stringWithFormat:@"%@\n%@",str1,str2];
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.purchaseBtn.mas_top).offset(-16);
        make.leading.equalTo(self).offset(40);
        make.trailing.equalTo(self).offset(-40);
    }];
    
    @weakify(self);
    [IAPInstance requestSku:@[self.detainmentIdentifier] completeBlock:^(NSError *error, NSArray *products) {
        @strongify(self);
        if (error || products.count == 0) {
            //
            //
            
            return;
        }
        SKProduct *product = [products firstObject];
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:product.priceLocale];
        NSString *formattedString = [numberFormatter stringFromNumber:product.price];
        if ([formattedString hasSuffix:@".00"]) {
            formattedString = [formattedString stringByReplacingOccurrencesOfString:@".00" withString:@""];
        }
        
        NSString *str1;
        {
            SKProductDiscount *discount = product.introductoryPrice;
            SKProductSubscriptionPeriod *period = discount.subscriptionPeriod;
            if (period.unit == SKProductPeriodUnitDay) {
                str1 = [NSString stringWithFormat:NSLocalizedString(@"str_freetrial_desc2", nil),@(period.numberOfUnits),formattedString];
            }else if (period.unit == SKProductPeriodUnitWeek) {
                str1 = [NSString stringWithFormat:NSLocalizedString(@"str_freetrial_desc2", nil),@(period.numberOfUnits * 7),formattedString];
            }
        }
        NSString *str2 = NSLocalizedString(@"str_cancelanytime", nil);
        self.tipLab.text = [NSString stringWithFormat:@"%@\n%@",str1,str2];
    }];
}

- (void)clickCloseButton {
    if (self.closeBlock) {
        self.closeBlock();
    }
}

- (void)clickPurchaseButton {
    [SVProgressHUD show];
    @weakify(self);
    [IAPInstance purchaseSku:self.detainmentIdentifier completeBlock:^(NSError *error, SKPaymentTransaction *transaction) {
        [SVProgressHUD dismiss];
        @strongify(self);
        if (error) {
            return;
        }
        
        if ([[HZIAPManager manager] isVip]) {
            if (self.buySuccessBlock) {
                self.buySuccessBlock();
            }
        }
    }];
}

@end
