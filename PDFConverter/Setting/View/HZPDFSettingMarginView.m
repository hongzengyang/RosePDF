//
//  HZPDFSettingMarginView.m
//  RosePDF
//
//  Created by THS on 2024/2/20.
//

#import "HZPDFSettingMarginView.h"
#import "HZCommonHeader.h"
#import "HZMarginSelectView.h"

@interface HZPDFSettingMarginView()
@property (nonatomic, strong) HZPDFSettingDataboard *databoard;

@property (nonatomic, assign) HZPDFMargin selectMargin;

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *marginLab;
@property (nonatomic, strong) UIImageView *iconImageView;

@end
@implementation HZPDFSettingMarginView

- (instancetype)initWithFrame:(CGRect)frame databoard:(HZPDFSettingDataboard *)databoard {
    if (self = [super initWithFrame:frame]) {
        self.databoard = databoard;
        
        self.selectMargin = (HZPDFMargin)[[[NSUserDefaults standardUserDefaults] valueForKey:pref_key_userSelect_margin] integerValue];
        
        [self configView];
    }
    return self;
}

- (void)configView {
    UILabel *titleLab = [[UILabel alloc] init];
    [self addSubview:titleLab];
    titleLab.font = [UIFont systemFontOfSize:17];
    titleLab.textColor = [UIColor blackColor];
    titleLab.text = NSLocalizedString(@"str_margin", nil);
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(16);
        make.top.equalTo(self);
        make.height.mas_equalTo(70);
        make.width.mas_equalTo(250);
    }];
    self.titleLab = titleLab;
    
    UIImageView *iconImageView = [[UIImageView alloc] init];
    [self addSubview:iconImageView];
    iconImageView.contentMode = UIViewContentModeCenter;
    iconImageView.image = [UIImage imageNamed:@"rose_pdfsetting_margin_arrow"];
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self).offset(-14);
        make.width.height.mas_equalTo(28);
    }];
    self.iconImageView = iconImageView;
    
    UILabel *marginLab = [[UILabel alloc] init];
    [self addSubview:marginLab];
    marginLab.font = [UIFont systemFontOfSize:14];
    marginLab.textColor = hz_getColor(@"888888");
    marginLab.text = [self marginTextWithMargin:self.selectMargin];
    [marginLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(iconImageView.mas_leading);
    }];
    self.marginLab = marginLab;
    
    UIView *separater = [[UIView alloc] init];
    [self addSubview:separater];
    separater.backgroundColor = hz_2_bgColor;
    [separater mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.titleLab);
        make.bottom.trailing.equalTo(self);
        make.height.mas_equalTo(1.0);
    }];
    
    
    UIButton *marginBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self addSubview:marginBtn];
    [marginBtn addTarget:self action:@selector(clickMarginButton) forControlEvents:(UIControlEventTouchUpInside)];
    marginBtn.backgroundColor = [UIColor clearColor];
    [marginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.trailing.equalTo(iconImageView);
        make.leading.equalTo(marginLab);
    }];
}

- (HZPDFMargin)currentMargin {
    return self.selectMargin;
}

- (void)clickMarginButton {
    @weakify(self);
    [HZMarginSelectView popWithMargin:self.selectMargin inView:[UIView hz_viewController].view relatedView:self.iconImageView selectBlock:^(NSInteger index) {
        @strongify(self);
        if (index != self.selectMargin) {
            self.selectMargin = index;
            self.marginLab.text = [self marginTextWithMargin:self.selectMargin];
        }
    }];
    
    [[UIView hz_viewController].view endEditing:YES];
}

- (NSString *)marginTextWithMargin:(HZPDFMargin)margin {
    NSString *text = @"";
    switch (margin) {
        case HZPDFMargin_normal:
            text = NSLocalizedString(@"str_normal", nil);
            break;
        case HZPDFMargin_none:
            text = NSLocalizedString(@"str_none", nil);
            break;
        default:
            break;
    }
    return text;
}

@end
