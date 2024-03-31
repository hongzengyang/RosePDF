//
//  HZHomeNavigationBar.m
//  RosePDF
//
//  Created by THS on 2024/2/5.
//

#import "HZHomeNavigationBar.h"
#import "HZCommonHeader.h"
#import "HZHomeMenuView.h"
#import "HZIAPManager.h"

@interface HZHomeNavigationBar()

@property (nonatomic, strong) UIVisualEffectView *visualEffectView;

@property (nonatomic, strong) UIView *normalContainerView;
@property (nonatomic, strong) UIButton *vipBtn;
@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIView *selectContainerView;
@property (nonatomic, strong) UIButton *selectAllBtn;
@property (nonatomic, strong) UIButton *finishBtn;
@property (nonatomic, strong) UILabel *selectLab;

@property (nonatomic, assign) BOOL isSelectMode;
@property (nonatomic, assign) BOOL isSwipeUpMode;

@end

@implementation HZHomeNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configView];
        [self configSelectMode:NO];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vipStatusChanged) name:notify_iap_changed object:nil];
    }
    return self;
}

- (void)configSelectMode:(BOOL)isSelectMode {
    self.isSelectMode = isSelectMode;
    self.normalContainerView.hidden = isSelectMode;
    self.selectContainerView.hidden = !isSelectMode;
}

- (void)configAllSelected:(BOOL)allSelected {
    self.selectAllBtn.selected = allSelected;
}

- (void)configSwipeUpMode:(BOOL)isSwipeUpMode {
    self.isSwipeUpMode = isSwipeUpMode;
    [self refreshWithAnimation:YES];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self.visualEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.normalContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.top.equalTo(self).offset(hz_safeTop);
    }];
    
    [self.selectContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.normalContainerView);
    }];
    
    [self.vipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.normalContainerView).offset(10);
        make.width.height.mas_equalTo(34);
        make.centerY.equalTo(self.normalContainerView);
    }];
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.normalContainerView).offset(-16);
        make.width.height.mas_equalTo(22);
        make.centerY.equalTo(self.vipBtn);
    }];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.vipBtn);
        make.centerX.equalTo(self.normalContainerView);
    }];
    
    [self.selectAllBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.selectContainerView).offset(16);
        make.centerY.equalTo(self.selectContainerView);
    }];
    [self.finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.selectContainerView).offset(-16);
        make.centerY.equalTo(self.selectAllBtn);
    }];
    [self.selectLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.selectAllBtn);
        make.centerX.equalTo(self.selectContainerView);
    }];
}

- (void)configView {
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.visualEffectView];
    [self addSubview:self.normalContainerView];
    [self addSubview:self.selectContainerView];
    
    [self refreshWithAnimation:NO];
}

- (void)viewWillAppear {
    BOOL isVip = [IAPInstance isVip];
    self.vipBtn.hidden = isVip;
}

- (void)refreshWithAnimation:(BOOL)animation {
    NSTimeInterval duration = animation ? 0.1 : 0;
    if (self.isSwipeUpMode) {
        [UIView animateWithDuration:duration animations:^{
            self.visualEffectView.alpha = 1.0;
            self.titleLab.alpha = 1.0;
        }];
    }else {
        [UIView animateWithDuration:duration animations:^{
            self.visualEffectView.alpha = 0.0;
            self.titleLab.alpha = 0.0;
        }];
    }
}

#pragma mark - Click
- (void)clickVipButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickIAPButton)]) {
        [self.delegate clickIAPButton];
    }
}

- (void)clickMoreButton {
    @weakify(self);
    [HZHomeMenuView popInView:[UIView hz_viewController].view relatedView:self selectBlock:^(HZHomeMenuType index) {
        @strongify(self);
        if (index == HZHomeMenuType_select) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(clickMultiSelectButton)]) {
                [self.delegate clickMultiSelectButton];
                [self configSelectMode:YES];
            }
        }else if (index == HZHomeMenuType_setting) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(clickAppSettingsButton)]) {
                [self.delegate clickAppSettingsButton];
            }
        }
    }];
}

- (void)clickSelectAllButton:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickSelectAllButton)]) {
            [self.delegate clickSelectAllButton];
        }
    }else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickCancelSelectAllButton)]) {
            [self.delegate clickCancelSelectAllButton];
        }
    }
}

- (void)clickFinishButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickSelectFinishButton)]) {
        [self.delegate clickSelectFinishButton];
    }
}

#pragma mark - Notification
- (void)vipStatusChanged {
    BOOL isVip = [IAPInstance isVip];
    self.vipBtn.hidden = isVip;
}

#pragma mark - Lazy
- (UIVisualEffectView *)visualEffectView {
    if (!_visualEffectView) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _visualEffectView = blurEffectView;
    }
    return _visualEffectView;
}

- (UIView *)normalContainerView {
    if (!_normalContainerView) {
        UIView *view = [[UIView alloc] init];
        _normalContainerView = view;
        
        [view addSubview:self.vipBtn];
        [view addSubview:self.moreBtn];
        [view addSubview:self.titleLab];
    }
    return _normalContainerView;
}

- (UIView *)selectContainerView {
    if (!_selectContainerView) {
        UIView *view = [[UIView alloc] init];
        _selectContainerView = view;
        
        [view addSubview:self.selectAllBtn];
        [view addSubview:self.finishBtn];
        [view addSubview:self.selectLab];
    }
    return _selectContainerView;
}

- (UIButton *)vipBtn {
    if (!_vipBtn) {
        _vipBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        _vipBtn.contentMode = UIViewContentModeCenter;
        [_vipBtn setImage:[UIImage imageNamed:@"rose_home_vip"] forState:(UIControlStateNormal)];
        [_vipBtn addTarget:self action:@selector(clickVipButton) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _vipBtn;
}

- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_moreBtn setImage:[UIImage imageNamed:@"rose_home_more"] forState:(UIControlStateNormal)];
        [_moreBtn addTarget:self action:@selector(clickMoreButton) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _moreBtn;
}
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:17 weight:(UIFontWeightMedium)];
        _titleLab.textColor = hz_1_textColor;
        _titleLab.text = NSLocalizedString(@"str_files", nil);
    }
    return _titleLab;
}

- (UIButton *)selectAllBtn {
    if (!_selectAllBtn) {
        _selectAllBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_selectAllBtn setTitle:[NSString stringWithFormat:@"  %@  ",NSLocalizedString(@"str_deselectall", nil)] forState:(UIControlStateSelected)];
        [_selectAllBtn setTitle:[NSString stringWithFormat:@"  %@  ",NSLocalizedString(@"str_selectall", nil)] forState:(UIControlStateNormal)];
        _selectAllBtn.layer.cornerRadius = 6;
        _selectAllBtn.layer.masksToBounds = YES;
        _selectAllBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_selectAllBtn setTitleColor:hz_main_color forState:(UIControlStateNormal)];
        [_selectAllBtn setTitleColor:hz_main_color forState:(UIControlStateSelected)];
        [_selectAllBtn addTarget:self action:@selector(clickSelectAllButton:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _selectAllBtn;
}

- (UIButton *)finishBtn {
    if (!_finishBtn) {
        _finishBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_finishBtn setTitle:[NSString stringWithFormat:@"  %@  ",NSLocalizedString(@"str_done", nil)] forState:(UIControlStateNormal)];
        [_finishBtn setBackgroundImage:[UIImage imageNamed:@"rose_gradient_bg"] forState:(UIControlStateNormal)];
        _finishBtn.layer.cornerRadius = 6;
        _finishBtn.layer.masksToBounds = YES;
        _finishBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_finishBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [_finishBtn addTarget:self action:@selector(clickFinishButton) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _finishBtn;
}
- (UILabel *)selectLab {
    if (!_selectLab) {
        _selectLab = [[UILabel alloc] init];
        _selectLab.font = [UIFont systemFontOfSize:17 weight:(UIFontWeightMedium)];
        _selectLab.textColor = hz_1_textColor;
        _selectLab.text = NSLocalizedString(@"str_selectfiles", nil);
    }
    return _selectLab;
}

@end
