//
//  HZAlbumPickerCell.m
//  HZAssetsPicker
//
//  Created by THS on 2024/2/18.
//

#import "HZAlbumPickerCell.h"
#import <HZUIKit/HZUIKit.h>
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface HZAlbumPickerCell()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *countLab;

@end

@implementation HZAlbumPickerCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configView];
    }
    return self;
}

- (void)configView {
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.countLab];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.top.leading.equalTo(self.contentView);
        make.height.equalTo(self.mas_width);
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView);
        make.top.equalTo(self.imageView.mas_bottom).offset(5);
        make.height.mas_equalTo(19);
    }];
    
    [self.countLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView);
        make.top.equalTo(self.titleLab.mas_bottom).offset(5);
        make.height.mas_equalTo(12);
    }];
}

- (void)configWithAlbum:(HZAlbum *)album {
    @weakify(self);
    [album requestThumbnailImageWithCompleteBlock:^(UIImage * _Nonnull image) {
        @strongify(self);
        self.imageView.image = image;
    }];
    
    self.titleLab.text = album.assetCollection.localizedTitle;
    [album requestAssetsCountWithCompleteBlock:^(NSInteger count) {
        @strongify(self);
        self.countLab.text = [NSString stringWithFormat:@"%@",@(count)];
    }];
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = 10;
        _imageView.backgroundColor = [UIColor hz_getColor:@"D9D9D9"];
    }
    return _imageView;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:15];
        _titleLab.textColor = [UIColor blackColor];
    }
    return _titleLab;
}

- (UILabel *)countLab {
    if (!_countLab) {
        _countLab = [[UILabel alloc] init];
        _countLab.font = [UIFont systemFontOfSize:15];
        _countLab.textColor = [UIColor hz_getColor:@"666666"];
    }
    return _countLab;
}
@end
