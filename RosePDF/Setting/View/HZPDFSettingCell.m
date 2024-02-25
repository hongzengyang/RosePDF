//
//  HZPDFSettingCell.m
//  RosePDF
//
//  Created by THS on 2024/2/20.
//

#import "HZPDFSettingCell.h"
#import "HZCommonHeader.h"

@interface HZPDFSettingCell()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) HZPageModel *pageModel;

@end

@implementation HZPDFSettingCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configView];
    }
    return self;
}

- (void)configView {
    [self.contentView addSubview:self.imageView];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)configWithModel:(HZPageModel *)pageModel {
    self.pageModel = pageModel;
    UIImage *originImage = [UIImage imageWithContentsOfFile:[pageModel resultPath]];
    originImage = [originImage hz_resizeImageToWidth:540];
    self.imageView.image = originImage;
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageView;
}

@end
