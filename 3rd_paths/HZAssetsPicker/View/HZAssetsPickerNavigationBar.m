//
//  HZAssetsPickerNavigationBar.m
//  HZAssetsPicker
//
//  Created by THS on 2024/2/7.
//

#import "HZAssetsPickerNavigationBar.h"
#import <HZUIKit/HZUIKit.h>
#import <Masonry/Masonry.h>

@interface HZAssetsPickerNavigationBar()

@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, assign) BOOL isSwipeUpMode;

@property (nonatomic, strong) UIView *separaterView;

@end

@implementation HZAssetsPickerNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configView];
    }
    return self;
}

- (void)configBackImage:(UIImage *)image {
    [self.backBtn setImage:image forState:(UIControlStateNormal)];
    [self updateConstraintsIfNeeded];
}

- (void)configRightTitle:(NSString *)title {
    if (!title) {
        self.rightBtn.hidden = YES;
    }else {
        self.rightBtn.hidden = NO;
    }
    
    [self.rightBtn setTitle:[NSString stringWithFormat:@"  %@  ",title] forState:(UIControlStateNormal)];
    [self.rightBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(28);
        make.trailing.equalTo(self).offset(-16);
        make.bottom.equalTo(self).offset(-8);
    }];
}

- (void)configTitle:(NSString *)title {
    self.titleLab.text = title;
    [self updateConstraintsIfNeeded];
}

- (void)configSwipeUpMode:(BOOL)isSwipeUpMode {
    self.isSwipeUpMode = isSwipeUpMode;
    [self refreshWithAnimation:YES];
}

- (void)configView {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [self addSubview:self.blurEffectView];
    [self.blurEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.backBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self addSubview:self.backBtn];
    [self.backBtn setImage:[UIImage imageNamed:@"rose_back"] forState:(UIControlStateNormal)];
    [self.backBtn addTarget:self action:@selector(clickBackButton) forControlEvents:(UIControlEventTouchUpInside)];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(28);
        make.leading.equalTo(self).offset(16);
        make.top.equalTo(self).offset([UIView hz_safeTop] + 8);
    }];
    
    self.rightBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self addSubview:self.rightBtn];
    [self.rightBtn setBackgroundImage:[UIImage imageNamed:@"rose_nav_right_bg"] forState:(UIControlStateNormal)];
    self.rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.rightBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [self.rightBtn addTarget:self action:@selector(clickRightButton) forControlEvents:(UIControlEventTouchUpInside)];
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(28);
        make.trailing.equalTo(self).offset(-12);
        make.centerY.equalTo(self.backBtn);
    }];
    
    self.titleLab = [[UILabel alloc] init];
    [self addSubview:self.titleLab];
    self.titleLab.font = [UIFont systemFontOfSize:17 weight:(UIFontWeightMedium)];
    self.titleLab.textColor = [UIColor blackColor];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backBtn);
        make.centerX.equalTo(self);
    }];
    
    self.separaterView = [[UIView alloc] init];
    [self addSubview:self.separaterView];
    self.separaterView.backgroundColor = [UIColor hz_getColor:@"000000" alpha:@"0.3"];
    [self.separaterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.leading.trailing.equalTo(self);
        make.height.mas_equalTo(0.33);
    }];
    
    [self refreshWithAnimation:NO];
}

- (void)updateConstraints {
    [super updateConstraints];
}

- (void)clickBackButton {
    if (self.clickBackBlock) {
        self.clickBackBlock();
    }
}
- (void)clickRightButton {
    if (self.clickRightBlock) {
        self.clickRightBlock();
    }
}


- (void)refreshWithAnimation:(BOOL)animation {
    NSTimeInterval duration = animation ? 0.1 : 0;
    if (self.isSwipeUpMode) {
        [UIView animateWithDuration:duration animations:^{
            self.blurEffectView.alpha = 1.0;
        } completion:^(BOOL finished) {
            self.backgroundColor = [UIColor clearColor];
        }];
    }else {
        [UIView animateWithDuration:duration animations:^{
            self.blurEffectView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.backgroundColor = [UIColor whiteColor];
        }];
    }
}

- (void)updateNextButtonEnable:(BOOL)enable {
    self.rightBtn.enabled = enable;
}

@end

