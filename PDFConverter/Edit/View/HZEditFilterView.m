//
//  HZEditFilterView.m
//  RosePDF
//
//  Created by THS on 2024/2/29.
//

#import "HZEditFilterView.h"
#import "HZCommonHeader.h"
#import "HZFilterManager.h"
#import "HZPageModel.h"
#import <HZUIKit/HZVerticalButton.h>
#import "HZEditFilterSliderView.h"
#import "HZFilterDebugView.h"

@interface HZEditFilterView()

@property (nonatomic, strong) HZEditDataboard *databoard;

@property (nonatomic, strong) UIButton *filterBtn;
@property (nonatomic, strong) UIButton *adjustBtn;

@property (nonatomic, strong) UIButton *completeBtn;
@property (nonatomic, strong) UIButton *applyAllBtn;

@property (nonatomic, strong) HZEditFilterSliderView *slider;

@property (nonatomic, strong) UIView *filterView;
@property (nonatomic, strong) UIView *adjustView;
@property (nonatomic, assign) BOOL isFocusAdjust;

@property (nonatomic, strong) NSMutableArray <UIButton *>*filterNamerray;
@property (nonatomic, strong) NSMutableArray <UIImageView *>*filterImagerray;
@property (nonatomic, strong) NSMutableArray <UIButton *>*filterButtonrray;

@property (nonatomic, strong) NSMutableArray <HZVerticalButton *>*adjustButtonrray;
@property (nonatomic, assign) HZAdjustType selectedAdjust;

@end

@implementation HZEditFilterView
- (instancetype)initWithFrame:(CGRect)frame databoard:(HZEditDataboard *)databoard {
    if (self = [super initWithFrame:frame]) {
        self.databoard = databoard;
        self.filterNamerray = [[NSMutableArray alloc] init];
        self.filterImagerray = [[NSMutableArray alloc] init];
        self.filterButtonrray = [[NSMutableArray alloc] init];
        self.adjustButtonrray = [[NSMutableArray alloc] init];
        
        [self configView];
        [self addDataboard];
    }
    return self;
}

- (void)configView {
    self.backgroundColor = [UIColor clearColor];
    
    self.applyAllBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.applyAllBtn.backgroundColor = hz_getColorWithAlpha(@"000000", 0.4);
    [self.applyAllBtn setImage:[UIImage imageNamed:@"rose_applyALL"] forState:(UIControlStateNormal)];
    self.applyAllBtn.layer.cornerRadius = 14;
    self.applyAllBtn.layer.masksToBounds = YES;
    [self.applyAllBtn addTarget:self action:@selector(clickApplyAllButton) forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:self.applyAllBtn];
    [self.applyAllBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-16);
        make.top.equalTo(self);
        make.width.mas_equalTo(95);
        make.height.mas_equalTo(28);
    }];
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 38, self.width, self.height - 38)];
    containerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:containerView];
    
    self.filterBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.filterBtn setTitle:NSLocalizedString(@"str_filter", nil) forState:(UIControlStateNormal)];
    self.filterBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:(UIFontWeightMedium)];
    [self.filterBtn addTarget:self action:@selector(clickFilterButton) forControlEvents:(UIControlEventTouchUpInside)];
    [containerView addSubview:self.filterBtn];
    [self.filterBtn sizeToFit];
    [self.filterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(containerView).offset(16);
        make.width.mas_equalTo(self.filterBtn.width);
        make.height.mas_equalTo(self.filterBtn.height);
    }];
    
    self.adjustBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.adjustBtn setTitle:NSLocalizedString(@"str_adjust", nil) forState:(UIControlStateNormal)];
    self.adjustBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:(UIFontWeightMedium)];
    [self.adjustBtn addTarget:self action:@selector(clickAdjustButton) forControlEvents:(UIControlEventTouchUpInside)];
    [containerView addSubview:self.adjustBtn];
    [self.adjustBtn sizeToFit];
    [self.adjustBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.filterBtn.mas_trailing).offset(14);
        make.centerY.equalTo(self.filterBtn);
        make.width.mas_equalTo(self.adjustBtn.width);
        make.height.mas_equalTo(self.adjustBtn.height);
    }];
    
    self.completeBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.completeBtn setImage:[UIImage imageNamed:@"rose_white_select"] forState:(UIControlStateNormal)];
    self.completeBtn.layer.cornerRadius = 10;
    self.completeBtn.layer.masksToBounds = YES;
    [self.completeBtn addTarget:self action:@selector(clickCompleteButton) forControlEvents:(UIControlEventTouchUpInside)];
    [containerView addSubview:self.completeBtn];
    [self.completeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(containerView).offset(-16);
        make.centerY.equalTo(self.filterBtn);
        make.width.mas_equalTo(38);
        make.height.mas_equalTo(28);
    }];
    [self.completeBtn setNeedsLayout];
    [self.completeBtn layoutIfNeeded];
    [self.completeBtn hz_addGradientWithColors:@[hz_main_color,hz_getColor(@"83BAF2")] startPoint:CGPointMake(0, 0.5) endPoint:CGPointMake(1, 0.5)];
    
    @weakify(self);
    self.slider = [[HZEditFilterSliderView alloc] initWithFrame:CGRectMake((containerView.width - 220)/2.0, 58, 220, 12)];
    self.slider.slideEndBlock = ^{
        @strongify(self);
        [self handleSlideChangedAction];
    };
    [containerView addSubview:self.slider];
    
    self.filterView = [[UIView alloc] init];
    self.filterView.backgroundColor = [UIColor whiteColor];
    [containerView addSubview:self.filterView];
    [self.filterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(containerView);
        make.top.equalTo(containerView).offset(86);
        make.height.mas_equalTo(58);
    }];
    {
        CGFloat itemWidth = 48;
        CGFloat itemHeight = 58;
        CGFloat interval = 24;
        CGFloat inset = (ScreenWidth - itemWidth * 4 - interval * 3) / 2.0;
        for (int i = 0; i < 4; i++) {
            UIView *view = [self createFilterViewWithType:i];
            [self.filterView addSubview:view];
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.filterView);
                make.leading.mas_equalTo(inset + i * (itemWidth + interval));
                make.width.mas_equalTo(itemWidth);
                make.height.mas_equalTo(itemHeight);
            }];
        }
        [self.filterView setNeedsLayout];
        [self.filterView layoutIfNeeded];
    }
    
    self.adjustView = [[UIView alloc] init];
    self.adjustView.backgroundColor = [UIColor whiteColor];
    [containerView addSubview:self.adjustView];
    [self.adjustView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.filterView);
    }];
    {
        NSArray *images = @[[UIImage imageNamed:@"rose_contrast_n"],[UIImage imageNamed:@"rose_brightness_n"],[UIImage imageNamed:@"rose_saturation_n"]];
        NSArray *selectedImages = @[[UIImage imageNamed:@"rose_contrast_s"],[UIImage imageNamed:@"rose_brightness_s"],[UIImage imageNamed:@"rose_saturation_s"]];
        NSArray *titles = @[NSLocalizedString(@"str_contrast", nil),NSLocalizedString(@"str_brightness", nil),NSLocalizedString(@"str_saturation", nil)];
        CGFloat btnWidth = 48;
        CGFloat btnHeight = 58;
        CGFloat space = 20.0;
        CGFloat startLeading = (ScreenWidth - btnWidth*3 - space*2)/2.0;
        for (int i = 0; i < images.count; i++) {
            HZVerticalButton *btn = [HZVerticalButton buttonWithSize:CGSizeMake(btnWidth, btnHeight) imageSize:CGSizeMake(40, 40) image:images[i] verticalSpacing:4 title:titles[i] titleColor:hz_1_textColor font:[UIFont systemFontOfSize:8]];
            [btn setSelectImage:selectedImages[i] selectTitleColor:hz_main_color];
            [self.adjustView addSubview:btn];
            btn.tag = i;
            [btn addTarget:self action:@selector(clickAdjustItemButton:) forControlEvents:(UIControlEventTouchUpInside)];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(startLeading + i * (btnWidth + space));
                make.top.equalTo(self.adjustView).offset(4.5);
                make.width.mas_equalTo(btnWidth);
                make.height.mas_equalTo(btnHeight);
            }];
            [self.adjustButtonrray addObject:btn];
        }
        [self.adjustView setNeedsLayout];
        [self.adjustView layoutIfNeeded];
    }
    
    [containerView hz_addCorner:(UIRectCornerTopLeft | UIRectCornerTopRight) radious:10];
    
    [self clickFilterButton];
    
    
    {//debug
        UIButton *debugBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [self addSubview:debugBtn];
        [debugBtn setTitle:@"debug" forState:(UIControlStateNormal)];
        debugBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:(UIFontWeightMedium)];
        [debugBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
        [debugBtn addTarget:self action:@selector(clickDebugButton) forControlEvents:(UIControlEventTouchUpInside)];
        [debugBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.completeBtn.mas_leading).offset(-16);
            make.centerY.equalTo(self.completeBtn);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(28);
        }];
        debugBtn.hidden = YES;
    }
}

- (UIView *)createFilterViewWithType:(HZFilterType)type {
    UIView *view = [[UIView alloc] init];
    view.layer.cornerRadius = 4;
    view.layer.masksToBounds = YES;
    view.backgroundColor = hz_getColor(@"B2B2B2");
    
    UIButton *nameLab = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [view addSubview:nameLab];
    nameLab.userInteractionEnabled = NO;
    nameLab.tag = type;
    nameLab.titleLabel.font = [UIFont systemFontOfSize:8];
    [nameLab setTitle:[HZFilterManager filterNameWithType:type] forState:(UIControlStateNormal)];
    [nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(view);
        make.height.mas_equalTo(16);
    }];
    [self.filterNamerray addObject:nameLab];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [view addSubview:imageView];
    imageView.tag = type;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(view);
        make.bottom.equalTo(nameLab.mas_top);
    }];
    [self.filterImagerray addObject:imageView];
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    button.tag = type;
    [button addTarget:self action:@selector(clickFilterItemButton:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.filterButtonrray addObject:button];
    
    return view;
}

- (void)addDataboard {
    @weakify(self);
    [[RACObserve(self.databoard, currentIndex) distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self update];
    }];
}

- (void)update {
    [self updateCurrentFilter];
    [self updateCurrentAdjust];
    [self updateSlider];
    
    if (self.databoard.project.pageModels.count <= 1) {
        self.applyAllBtn.hidden = YES;
    }else {
        self.applyAllBtn.hidden = NO;
    }
}

- (void)updateCurrentFilter {
    HZPageModel *pageModel = [self.databoard currentPage];
    [self.filterNamerray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == pageModel.filter.filterType) {
            [obj setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
            [obj hz_addGradientWithColors:@[hz_main_color,hz_getColor(@"83BAF2")] startPoint:CGPointMake(0, 0.5) endPoint:CGPointMake(1, 0.5)];
        }else {
            [obj setTitleColor:hz_1_textColor forState:(UIControlStateNormal)];
            [obj hz_addGradientWithColors:@[hz_3_bgColor,hz_3_bgColor] startPoint:CGPointMake(0, 0.5) endPoint:CGPointMake(1, 0.5)];
        }
    }];
}

- (void)updateCurrentAdjust {
    HZPageModel *pageModel = [self.databoard currentPage];
    for (int i = 0; i < self.adjustButtonrray.count; i++) {
        HZVerticalButton *button = [self.adjustButtonrray objectAtIndex:i];
        [button verticalButtonSelected:button.tag == self.selectedAdjust];
    }
}

- (void)updateSlider {
    HZPageModel *currentPage = [self.databoard currentPage];
    HZValueModel *valueModel;
    if (!self.isFocusAdjust) {
        if (currentPage.filter.filterType == HZFilter_none) {
            self.slider.hidden = YES;
        }else {
            self.slider.hidden = NO;
            valueModel = currentPage.filter.value;
        }
    }else {
        self.slider.hidden = NO;
        switch (self.selectedAdjust) {
            case HZAdjust_contrast:{
                valueModel = currentPage.adjust.contrastValue;
            }
                break;
            case HZAdjust_brightness:{
                valueModel = currentPage.adjust.brightnessValue;
            }
                break;
            case HZAdjust_saturation:{
                valueModel = currentPage.adjust.saturationValue;
            }
                break;
            default:
                break;
        }
    }
    if (valueModel) {
        [self.slider updateWithMin:valueModel.min max:valueModel.max value:valueModel.intensity defaultValue:valueModel.defaultValue];
    }
}

- (void)clickFilterButton {
    [self.filterBtn setTitleColor:hz_main_color forState:(UIControlStateNormal)];
    [self.adjustBtn setTitleColor:hz_getColor(@"666666") forState:(UIControlStateNormal)];
    self.filterBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:(UIFontWeightMedium)];
    self.adjustBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:(UIFontWeightRegular)];
    
    [self.filterView.superview bringSubviewToFront:self.filterView];
    self.isFocusAdjust = NO;
    [self update];
}

- (void)clickAdjustButton {
    [self.filterBtn setTitleColor:hz_getColor(@"666666") forState:(UIControlStateNormal)];
    [self.adjustBtn setTitleColor:hz_main_color forState:(UIControlStateNormal)];
    self.filterBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:(UIFontWeightRegular)];
    self.adjustBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:(UIFontWeightMedium)];
    
    [self.adjustView.superview bringSubviewToFront:self.adjustView];
    self.isFocusAdjust = YES;
    [self update];
}

- (void)clickCompleteButton {
    if (self.completeBlock) {
        self.completeBlock(NO);
    }
}

- (void)clickApplyAllButton {
    if (self.completeBlock) {
        self.completeBlock(YES);
    }
}

- (void)handleSlideChangedAction {
    HZPageModel *currentPage = [self.databoard currentPage];
    HZValueModel *valueModel;
    BOOL isFilter = NO;
    if (!self.isFocusAdjust) {
        if (currentPage.filter.filterType == HZFilter_none) {
            
        }else {
            valueModel = currentPage.filter.value;
            isFilter = YES;
        }
    }else {
        switch (self.selectedAdjust) {
            case HZAdjust_contrast:{
                valueModel = currentPage.adjust.contrastValue;
            }
                break;
            case HZAdjust_brightness:{
                valueModel = currentPage.adjust.brightnessValue;
            }
                break;
            case HZAdjust_saturation:{
                valueModel = currentPage.adjust.saturationValue;
            }
                break;
            default:
                break;
        }
    }
    
    if (valueModel) {
        valueModel.intensity = self.slider.value;
        if (self.slideBlock) {
            self.slideBlock(isFilter, currentPage.filter.filterType, self.selectedAdjust);
        }
    }
}

- (void)clickFilterItemButton:(UIButton *)button {
    HZFilterType selectType = button.tag;
    HZPageModel *currentPage = [self.databoard currentPage];
    if (selectType == currentPage.filter.filterType) {
        return;
    }
    
    currentPage.filter = [HZFilterManager defaultFilterModel:selectType];
    currentPage.adjust = [HZFilterManager defaultAdjustModel];
    [self update];
    if (self.clickFilterItemBlock) {
        self.clickFilterItemBlock(selectType);
    }
}

- (void)clickAdjustItemButton:(UIButton *)button {
    HZAdjustType adjustType = button.tag;
    if (adjustType == self.selectedAdjust) {
        return;
    }
    
    self.selectedAdjust = adjustType;
    [self update];
}

- (void)clickDebugButton {
    HZPageModel *page = [self.databoard currentPage];
    UIImage *image = [UIImage imageWithContentsOfFile:[page contentPath]];
    HZFilterDebugView *view = [[HZFilterDebugView alloc] initWithFrame:[UIScreen mainScreen].bounds image:image];
    [[UIView hz_viewController].view addSubview:view];
}


@end
