//
//  HZHomeNavigationBar.m
//  RosePDF
//
//  Created by THS on 2024/2/5.
//

#import "HZHomeNavigationBar.h"
#import "HZCommonHeader.h"

@interface HZHomeNavigationBar()

@property (nonatomic, strong) UIVisualEffectView *visualEffectView;
@property (nonatomic, strong) UIButton *vipBtn;
@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, assign) BOOL isSelectMode;
@property (nonatomic, assign) BOOL isSwipeUpMode;

@end

@implementation HZHomeNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configView];
    }
    return self;
}

- (void)configSelectMode:(BOOL)isSelectMode {
    self.isSelectMode = isSelectMode;
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
    
    [self.vipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(16);
        make.width.height.mas_equalTo(22);
        make.bottom.equalTo(self).offset(-19);
    }];
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-16);
        make.width.height.mas_equalTo(22);
        make.centerY.equalTo(self.vipBtn);
    }];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.vipBtn);
        make.centerX.equalTo(self);
    }];
}

- (void)configView {
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.visualEffectView];
    [self addSubview:self.vipBtn];
    [self addSubview:self.moreBtn];
    [self addSubview:self.titleLab];
    
    [self refreshWithAnimation:NO];
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
    
}

- (void)clickMoreButton {
    
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
- (UIButton *)vipBtn {
    if (!_vipBtn) {
        _vipBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
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
        _titleLab.font = [UIFont systemFontOfSize:17];
        _titleLab.textColor = hz_1_textColor;
        _titleLab.text = NSLocalizedString(@"str_files", nil);
    }
    return _titleLab;
}

@end
