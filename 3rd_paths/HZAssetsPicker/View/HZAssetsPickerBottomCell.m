//
//  HZAssetsPickerBottomCell.m
//  HZAssetsPicker
//
//  Created by THS on 2024/2/18.
//

#import "HZAssetsPickerBottomCell.h"
#import <HZUIKit/HZUIKit.h>
#import <Masonry/Masonry.h>

@interface HZAssetsPickerBottomCell()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) HZAsset *asset;

@end

@implementation HZAssetsPickerBottomCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configView];
    }
    return self;
}

- (void)configView {
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.closeBtn];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.top.equalTo(self.contentView);
        make.width.height.mas_equalTo(22);
    }];
}

- (void)configWithAsset:(HZAsset *)asset {
    self.asset = asset;
    __weak typeof(self) weakSelf = self;
    [asset requestThumbnailWithCompleteBlock:^(UIImage * _Nonnull image) {
        weakSelf.imageView.image = image;
    }];
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (void)clickCloseButton {
    if (self.clickDeleteBlock) {
        self.clickDeleteBlock(self.asset);
    }
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds = YES;
    }
    return _imageView;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_closeBtn addTarget:self action:@selector(clickCloseButton) forControlEvents:(UIControlEventTouchUpInside)];
        [_closeBtn setImage:[UIImage imageNamed:@"rose_asset_remove"] forState:(UIControlStateNormal)];
    }
    return _closeBtn;
}

@end
