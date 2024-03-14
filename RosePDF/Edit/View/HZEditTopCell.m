//
//  HZEditTopCell.m
//  RosePDF
//
//  Created by THS on 2024/2/6.
//

#import "HZEditTopCell.h"
#import "HZCommonHeader.h"

@interface HZEditTopCell()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) HZPageModel *pageModel;

@end

@implementation HZEditTopCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configView];
    }
    return self;
}

- (void)configView {
    [self.contentView addSubview:self.imageView];
    self.layer.cornerRadius = 6;
    self.layer.masksToBounds = YES;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)configWithModel:(HZPageModel *)pageModel isAdd:(BOOL)isAdd {
    self.pageModel = pageModel;
    self.imageView.image = nil;
    if (isAdd) {
        self.imageView.image = [UIImage imageNamed:@"rose_edit_top_add"];
    }else {
        UIImage *previewImage = [UIImage imageWithContentsOfFile:[pageModel previewPath]];
        self.imageView.image = previewImage;
    }
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (void)configSelected:(BOOL)selected {
    if (selected) {
        self.layer.borderWidth = 1.5;
        self.layer.borderColor = hz_main_color.CGColor;
    }else {
        self.layer.borderWidth = 0.0;
    }
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageView;
}

@end
