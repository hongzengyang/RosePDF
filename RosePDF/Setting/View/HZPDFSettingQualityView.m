//
//  HZPDFSettingQualityView.m
//  RosePDF
//
//  Created by THS on 2024/2/20.
//

#import "HZPDFSettingQualityView.h"
#import "HZCommonHeader.h"
#import "HZSelectPopView.h"

@interface HZPDFSettingQualityView()
@property (nonatomic, strong) HZPDFSettingDataboard *databoard;

@property (nonatomic, assign) HZPDFQuality selectQuality;

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *qualityLab;
@property (nonatomic, strong) UIImageView *iconImageView;

@end
@implementation HZPDFSettingQualityView

- (instancetype)initWithFrame:(CGRect)frame databoard:(HZPDFSettingDataboard *)databoard {
    if (self = [super initWithFrame:frame]) {
        self.databoard = databoard;
        
        self.selectQuality = databoard.project.quality;
        
        [self configView];
    }
    return self;
}

- (void)configView {
    UILabel *titleLab = [[UILabel alloc] init];
    [self addSubview:titleLab];
    titleLab.font = [UIFont systemFontOfSize:17];
    titleLab.textColor = [UIColor blackColor];
    titleLab.text = NSLocalizedString(@"str_quality", nil);
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
    
    UILabel *qualityLab = [[UILabel alloc] init];
    [self addSubview:qualityLab];
    qualityLab.font = [UIFont systemFontOfSize:14];
    qualityLab.textColor = hz_getColor(@"888888");
    qualityLab.text = [self qualityTextWithQuality:self.selectQuality];
    [qualityLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(iconImageView.mas_leading);
    }];
    self.qualityLab = qualityLab;
    
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
    [marginBtn addTarget:self action:@selector(clickQualityButton) forControlEvents:(UIControlEventTouchUpInside)];
    marginBtn.backgroundColor = [UIColor clearColor];
    [marginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.trailing.equalTo(iconImageView);
        make.leading.equalTo(qualityLab);
    }];
}

- (HZPDFQuality)currentQuality {
    return self.selectQuality;
}

- (void)clickQualityButton {
    NSArray *items = @[
        [self qualityTextWithQuality:(HZPDFQuality_100)],
        [self qualityTextWithQuality:(HZPDFQuality_75)],
        [self qualityTextWithQuality:(HZPDFQuality_50)],
        [self qualityTextWithQuality:(HZPDFQuality_25)]
    ];
    NSString *curItem = [self qualityTextWithQuality:self.selectQuality];
    NSInteger index = 0;
    if ([items containsObject:curItem]) {
        index = [items indexOfObject:curItem];
    }
    @weakify(self);
    [HZSelectPopView popWithItems:items index:index inView:[UIView hz_viewController].view relatedView:self.iconImageView type:(HZSelectPopType_quality) selectBlock:^(NSInteger index) {
        @strongify(self);
        if (index != self.selectQuality) {
            self.selectQuality = index;
            self.qualityLab.text = [self qualityTextWithQuality:self.selectQuality];
        }
    }];
    
    [[UIView hz_viewController].view endEditing:YES];
}

- (NSString *)qualityTextWithQuality:(HZPDFQuality)quality {
    NSString *text = @"";
    switch (quality) {
        case HZPDFQuality_100:
            text = @"100%";
            break;
        case HZPDFQuality_75:
            text = @"75%";
            break;
        case HZPDFQuality_50:
            text = @"50%";
            break;
        case HZPDFQuality_25:
            text = @"25%";
            break;
        default:
            break;
    }
    return text;
}

@end

