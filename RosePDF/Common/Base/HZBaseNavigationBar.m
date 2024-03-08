//
//  HZBaseNavigationBar.m
//  RosePDF
//
//  Created by THS on 2024/2/6.
//

#import "HZBaseNavigationBar.h"
#import "HZCommonHeader.h"

@interface HZBaseNavigationBar()

@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIView *separaterView;

@end

@implementation HZBaseNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configView];
    }
    return self;
}

- (void)configBackImage:(UIImage *)image {
    if (!image) {
        self.backBtn.hidden = YES;
    }else {
        self.backBtn.hidden = NO;
    }
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
        make.trailing.equalTo(self).offset(-12);
        make.bottom.equalTo(self).offset(-8);
    }];
}

- (void)configTitle:(NSString *)title {
    self.titleLab.text = title;
    [self updateConstraintsIfNeeded];
}

- (void)setBackHidden:(BOOL)hidden {
    self.backBtn.hidden = hidden;
}

- (void)setRightHidden:(BOOL)hidden {
    self.rightBtn.hidden = hidden;
}

- (void)configView {
    self.backgroundColor = [UIColor whiteColor];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [self addSubview:blurEffectView];
    [blurEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.backBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self addSubview:self.backBtn];
    [self.backBtn setImage:[UIImage imageNamed:@"rose_back"] forState:(UIControlStateNormal)];
    [self.backBtn addTarget:self action:@selector(clickBackButton) forControlEvents:(UIControlEventTouchUpInside)];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(28);
        make.leading.equalTo(self).offset(12);
        make.bottom.equalTo(self).offset(-8);
    }];
    
    self.rightBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self addSubview:self.rightBtn];
    [self.rightBtn setBackgroundImage:[UIImage imageNamed:@"rose_nav_right_bg"] forState:(UIControlStateNormal)];
    self.rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.rightBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [self.rightBtn addTarget:self action:@selector(clickRightButton) forControlEvents:(UIControlEventTouchUpInside)];
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(28);
//        make.width.mas_equalTo(56);
        make.trailing.equalTo(self).offset(-12);
        make.bottom.equalTo(self).offset(-8);
    }];
    
    self.titleLab = [[UILabel alloc] init];
    [self addSubview:self.titleLab];
    self.titleLab.font = [UIFont systemFontOfSize:17 weight:(UIFontWeightMedium)];
    self.titleLab.textColor = hz_1_textColor;
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backBtn);
        make.centerX.equalTo(self);
    }];
    
    self.separaterView = [[UIView alloc] init];
    [self addSubview:self.separaterView];
    self.separaterView.backgroundColor = hz_getColorWithAlpha(@"000000", 0.3);
    [self.separaterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.leading.trailing.equalTo(self);
        make.height.mas_equalTo(0.33);
    }];
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

@end
