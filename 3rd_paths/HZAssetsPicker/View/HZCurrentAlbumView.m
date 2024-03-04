//
//  HZCurrentAlbumView.m
//  HZAssetsPicker
//
//  Created by THS on 2024/2/7.
//

#import "HZCurrentAlbumView.h"
#import <HZUIKit/HZUIKit.h>
#import <HZFoundationKit/HZFoundationKit.h>
#import <Masonry/Masonry.h>

@interface HZCurrentAlbumView()

@property (nonatomic, strong) HZAlbum *album;

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UIButton *clickBtn;

@end

@implementation HZCurrentAlbumView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configView];
    }
    return self;
}

- (void)configView {
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = 6;
    self.layer.masksToBounds = YES;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [self addSubview:blurEffectView];
    [blurEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    
    self.titleLab = [[UILabel alloc] init];
    self.titleLab.textColor = [UIColor blackColor];
    self.titleLab.font = [UIFont systemFontOfSize:14];
    self.titleLab.text = @"     "; //站位
    [self addSubview:self.titleLab];
    
    self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rose_pick_arrow"]];
    [self addSubview:self.arrowImageView];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(9);
        make.centerY.equalTo(self);
        make.trailing.equalTo(self.arrowImageView.mas_leading).offset(-4);
    }];
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self).offset(-9);
        make.width.height.mas_equalTo(16);
    }];
    
    self.clickBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.clickBtn addTarget:self action:@selector(clickButton) forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:self.clickBtn];
    [self.clickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)updateWithAlbum:(HZAlbum *)album {
    self.album = album;
    self.titleLab.text = album.assetCollection.localizedTitle;
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (void)clickButton {
    if (self.ClickBlock) {
        self.ClickBlock();        
    }
}

@end
