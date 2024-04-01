//
//  HZIAPViewController.m
//  RosePDF
//
//  Created by THS on 2024/3/25.
//

#import "HZIAPViewController.h"
#import "HZCommonHeader.h"
#import "HZIAPManager.h"
#import "HZPDFWebViewController.h"

@interface HZIAPViewController ()

@property (nonatomic, strong) UILabel *tipLab;
@property (nonatomic, strong) UIButton *purchaseBtn;

@end

@implementation HZIAPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configView];
    @weakify(self);
    [IAPInstance requestSku:@[sku_weekly] completeBlock:^(NSError *error, NSArray *products) {
        @strongify(self);
        if (error || products.count == 0) {
            //
            //
            
            return;
        }
        SKProduct *product = [products firstObject];
        [self refreshPriceLabWithProduct:product];
    }];
}

- (void)configView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *bgImageView = [[UIImageView alloc] init];
    [self.view addSubview:bgImageView];
    if ([[HZSystemManager manager] iPadDevice]) {
        bgImageView.image = [UIImage imageNamed:@"rose_iap_bg_ipad"];
    }else {
        bgImageView.image = [UIImage imageNamed:@"rose_iap_bg"];
    }
    [bgImageView sizeToFit];
    [bgImageView setFrame:CGRectMake(0, 0, self.view.width, self.view.width / (bgImageView.size.width / bgImageView.size.height))];
    
    UIButton *closeBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.view addSubview:closeBtn];
    [closeBtn setImage:[UIImage imageNamed:@"rose_iap_close"] forState:(UIControlStateNormal)];
    [closeBtn addTarget:self action:@selector(clickCloseButton) forControlEvents:(UIControlEventTouchUpInside)];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(22);
        make.top.equalTo(self.view).offset(hz_safeTop);
        make.width.height.mas_equalTo(28);
    }];
    
    UIButton *restoreBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.view addSubview:restoreBtn];
    [restoreBtn addTarget:self action:@selector(clickRestoreButton) forControlEvents:(UIControlEventTouchUpInside)];
    [restoreBtn setTitle:NSLocalizedString(@"str_restore", nil) forState:(UIControlStateNormal)];
    restoreBtn.titleLabel.font = [UIFont systemFontOfSize:10 weight:(UIFontWeightBold)];
    [restoreBtn setTitleColor:hz_getColorWithAlpha(@"000000", 0.5) forState:(UIControlStateNormal)];
    [restoreBtn sizeToFit];
    [restoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view).offset(-22);
        make.centerY.equalTo(closeBtn);
        make.width.mas_equalTo(restoreBtn.width);
        make.height.mas_equalTo(restoreBtn.height);
    }];
    
    UIView *containerView = [[UIView alloc] init];
    {
        [self.view addSubview:containerView];

        UIButton *TermsConditions = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [containerView addSubview:TermsConditions];
        [TermsConditions addTarget:self action:@selector(clickTermsConditionsButton) forControlEvents:(UIControlEventTouchUpInside)];
        [TermsConditions setTitle:NSLocalizedString(@"str_terms", nil) forState:(UIControlStateNormal)];
        TermsConditions.titleLabel.font = [UIFont systemFontOfSize:10 weight:(UIFontWeightRegular)];
        [TermsConditions setTitleColor:hz_getColorWithAlpha(@"000000", 0.5) forState:(UIControlStateNormal)];
        [TermsConditions sizeToFit];
        
        UIButton *privacy = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [containerView addSubview:privacy];
        [privacy addTarget:self action:@selector(clickPrivacyButton) forControlEvents:(UIControlEventTouchUpInside)];
        [privacy setTitle:NSLocalizedString(@"str_privacy", nil) forState:(UIControlStateNormal)];
        privacy.titleLabel.font = [UIFont systemFontOfSize:10 weight:(UIFontWeightRegular)];
        [privacy setTitleColor:hz_getColorWithAlpha(@"000000", 0.5) forState:(UIControlStateNormal)];
        [privacy sizeToFit];
        
        UIView *vertical = [[UIView alloc] init];
        [containerView addSubview:vertical];
        vertical.backgroundColor = hz_getColorWithAlpha(@"000000", 0.5);
        
        [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(TermsConditions.width + privacy.width + 10);
            make.bottom.equalTo(self.view).offset(-hz_safeBottom - 4);
            make.centerX.equalTo(self.view);
            make.height.mas_equalTo(12);
        }];
        [TermsConditions mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.bottom.equalTo(containerView);
            make.width.mas_equalTo(TermsConditions.width);
        }];
        [privacy mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.top.bottom.equalTo(containerView);
            make.width.mas_equalTo(privacy.width);
        }];
        [vertical mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(containerView);
            make.leading.equalTo(TermsConditions.mas_trailing).offset(5);
            make.width.mas_equalTo(1);
        }];
    }
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    UIButton *purchaseBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.purchaseBtn = purchaseBtn;
    [self.view addSubview:purchaseBtn];
    purchaseBtn.layer.cornerRadius = 16;
    purchaseBtn.layer.masksToBounds = YES;
    [purchaseBtn setTitle:NSLocalizedString(@"str_continue", nil) forState:(UIControlStateNormal)];
    purchaseBtn.titleLabel.font = [UIFont systemFontOfSize:17 weight:(UIFontWeightBold)];
    [purchaseBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [purchaseBtn addTarget:self action:@selector(clickPurchaseButton) forControlEvents:(UIControlEventTouchUpInside)];
    [purchaseBtn setFrame:CGRectMake((self.view.width - 254)/2.0, containerView.top - 16 - 56, 254, 56)];
    [purchaseBtn hz_addGradientWithColors:@[hz_main_color,hz_getColor(@"83BAF2")] startPoint:CGPointMake(0, 0.5) endPoint:CGPointMake(1, 0.5)];
    
    self.tipLab = [[UILabel alloc] init];
    self.tipLab.numberOfLines = 0;
    self.tipLab.font = [UIFont systemFontOfSize:10];
    self.tipLab.textAlignment = NSTextAlignmentCenter;
    self.tipLab.textColor = hz_getColorWithAlpha(@"000000", 0.6);
    [self.view addSubview:self.tipLab];
    
    CGFloat targetWidth = self.view.width - 7 - 7;
    UILabel *desc2 = [[UILabel alloc] init];
    [self.view addSubview:desc2];
    desc2.numberOfLines = 0;
    NSMutableParagraphStyle *textStyle2 = [[NSMutableParagraphStyle alloc] init];
    textStyle2.alignment = NSTextAlignmentCenter;
    textStyle2.lineSpacing = 6;
    NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"str_premium_desc2", nil) attributes:@{NSForegroundColorAttributeName:hz_getColor(@"3D414B"),NSFontAttributeName : [UIFont systemFontOfSize:24 weight:(UIFontWeightBold)],NSParagraphStyleAttributeName : textStyle2}];
    desc2.attributedText = str2;
    [desc2 sizeToFit];
    if (desc2.width > targetWidth) {
        desc2.width = targetWidth;
        [desc2 sizeToFit];
    }
    [desc2 setFrame:CGRectMake((self.view.width - desc2.width)/2.0, purchaseBtn.top - 44 - desc2.height, desc2.width, desc2.height)];
    
    UILabel *desc1 = [[UILabel alloc] init];
    [self.view addSubview:desc1];
    desc1.numberOfLines = 0;
    NSMutableParagraphStyle *textStyle1 = [[NSMutableParagraphStyle alloc] init];
    textStyle1.alignment = NSTextAlignmentCenter;
    textStyle1.lineSpacing = 6;
    NSAttributedString *str1 = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"str_premium_desc1", nil) attributes:@{NSForegroundColorAttributeName:hz_getColor(@"3D414B"),NSFontAttributeName : [UIFont systemFontOfSize:24 weight:(UIFontWeightBold)],NSParagraphStyleAttributeName : textStyle1}];
    desc1.attributedText = str1;
    [desc1 sizeToFit];
    if (desc1.width > targetWidth) {
        desc1.width = targetWidth;
        [desc1 sizeToFit];
    }
    [desc1 setFrame:CGRectMake((self.view.width - desc1.width)/2.0, desc2.top - 6 - desc1.height, desc1.width, desc1.height)];

}

- (void)refreshPriceLabWithProduct:(SKProduct *)product {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:product.price];
    if ([formattedString hasSuffix:@".00"]) {
        formattedString = [formattedString stringByReplacingOccurrencesOfString:@".00" withString:@""];
    }
    
    NSString *text1 = [NSString stringWithFormat:NSLocalizedString(@"str_price", nil),formattedString];
    NSString *text2 = NSLocalizedString(@"str_cancelanytime", nil);
    self.tipLab.text = [NSString stringWithFormat:@"%@%@",text1,text2];
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(60);
        make.trailing.equalTo(self.view).offset(-60);
        make.bottom.equalTo(self.purchaseBtn.mas_top).offset(-6);
    }];
}

- (void)clickCloseButton {
    if (self.clickCloseBlock) {
        self.clickCloseBlock();
    }
}

- (void)clickRestoreButton {
    [SVProgressHUD show];
    @weakify(self);
    [IAPInstance restoreWithCompleteBlock:^(BOOL suc) {
        [SVProgressHUD dismiss];
        @strongify(self);
        if (!suc) {
            NSLog(@"debug--restore fail");
        }else {
            NSLog(@"debug--restore success");
            if (self.successBlock) {
                self.successBlock();
            }
        }
    }];
}

- (void)clickTermsConditionsButton {
    HZPDFWebViewController *vc = [[HZPDFWebViewController alloc] initWithUrl:[[NSBundle mainBundle] pathForResource:@"Terms_Conditions" ofType:@"pdf"] title:NSLocalizedString(@"str_terms", nil)];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clickPrivacyButton {
    HZPDFWebViewController *vc = [[HZPDFWebViewController alloc] initWithUrl:[[NSBundle mainBundle] pathForResource:@"PrivacyPolicy" ofType:@"pdf"] title:NSLocalizedString(@"str_privacy", nil)];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clickPurchaseButton {
    [SVProgressHUD show];
    @weakify(self);
    [IAPInstance purchaseSku:sku_weekly completeBlock:^(NSError *error, SKPaymentTransaction *transaction) {
        [SVProgressHUD dismiss];
        @strongify(self);
        if (error) {
            NSLog(@"debug--purchase fail");
        }else {
            NSLog(@"debug--purchase success");
            if ([[HZIAPManager manager] isVip]) {
                if (self.successBlock) {
                    self.successBlock();
                }
            }
        }
    }];
}

@end
