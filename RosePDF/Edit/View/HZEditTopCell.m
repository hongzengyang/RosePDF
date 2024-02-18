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
    if (isAdd) {
        self.imageView.image = [UIImage imageNamed:@"rose_edit_top_add"];
    }else {
        self.imageView.image = nil;
    }
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

@end
