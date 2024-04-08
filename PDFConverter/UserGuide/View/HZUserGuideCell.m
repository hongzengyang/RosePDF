//
//  HZUserGuideCell.m
//  RosePDF
//
//  Created by THS on 2024/3/21.
//

#import "HZUserGuideCell.h"
#import "HZCommonHeader.h"

@interface HZUserGuideCell()

@property (nonatomic, strong) UIImageView *guideImageView;
@property (nonatomic, strong) UIImageView *bottomBgImageView;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIButton *nextBtn;

@end

@implementation HZUserGuideCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configView];
    }
    return self;
}

- (void)configView {
    self.guideImageView = [[UIImageView alloc] init];
    self.guideImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.guideImageView];
    
    self.bottomBgImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.bottomBgImageView];
    
    self.titleLab = [[UILabel alloc] init];
    self.titleLab.font = [UIFont systemFontOfSize:28 weight:(UIFontWeightMedium)];
    self.titleLab.textColor = hz_getColor(@"484850");
    self.titleLab.numberOfLines = 0;
    self.titleLab.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.titleLab];
    
    self.nextBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.contentView addSubview:self.nextBtn];
    self.nextBtn.layer.cornerRadius = 16;
    self.nextBtn.layer.masksToBounds = YES;
    [self.nextBtn setTitle:NSLocalizedString(@"str_continue", nil) forState:(UIControlStateNormal)];
    self.nextBtn.titleLabel.font = [UIFont systemFontOfSize:17 weight:(UIFontWeightBold)];
    [self.nextBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [self.nextBtn addTarget:self action:@selector(clickNext) forControlEvents:(UIControlEventTouchUpInside)];
}

- (void)configWithImageName:(NSString *)name title:(NSString *)title {
    UIImage *guideImage = [UIImage imageNamed:name] ;
    UIImage *bottomBgImage = [UIImage imageNamed:@"rose_guide_bottom_bg"];
    
    self.titleLab.text = title;
    
    [self.guideImageView setFrame:self.contentView.bounds];
    self.guideImageView.image = guideImage;
    
    CGFloat bottomImgWidth = self.contentView.width;
    CGFloat bottomImgHeight;
    if ([[HZSystemManager manager] iPadDevice]) {
        bottomImgHeight = bottomImgWidth / (1024.0 / 427.0);
    }else {
        bottomImgHeight = bottomImgWidth / (375.0 / 225.0);
    }
    [self.bottomBgImageView setFrame:CGRectMake(0, self.contentView.height - bottomImgHeight, bottomImgWidth, bottomImgHeight)];
    self.bottomBgImageView.image = bottomBgImage;
    
    CGFloat titleWidth = self.contentView.width - 49 - 49;
    self.titleLab.width = titleWidth;
    [self.titleLab sizeToFit];
    [self.titleLab setFrame:CGRectMake(49, self.bottomBgImageView.top + 28, titleWidth, self.titleLab.height)];
    
    [self.nextBtn setFrame:CGRectMake(60, self.contentView.height - hz_safeBottom - 32 - 56, self.contentView.width - 120, 56)];
    [self.nextBtn hz_addGradientWithColors:@[hz_main_color,hz_getColor(@"83BAF2")] startPoint:CGPointMake(0, 0.5) endPoint:CGPointMake(1, 0.5)];
    
    if (self.titleLab.bottom > self.nextBtn.top) {
        [self.titleLab setFrame:CGRectMake(5, self.bottomBgImageView.top, self.contentView.width - 5 - 5, self.nextBtn.top - 2 - (self.bottomBgImageView.top))];
    }
}

- (void)clickNext {
    if (self.clickNextBlock) {
        self.clickNextBlock();
    }
}

@end
