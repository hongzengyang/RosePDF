//
//  HZCameraPreviewView.m
//  HZAssetsPicker
//
//  Created by THS on 2024/3/5.
//

#import "HZCameraPreviewView.h"
#import <HZUIKit/HZUIKit.h>
#import <Masonry/Masonry.h>

@interface HZCameraPreviewView()

@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UILabel *countLab;

@end

@implementation HZCameraPreviewView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configView];
    }
    return self;
}

- (void)configView {
    self.backgroundColor = [UIColor clearColor];
    
    self.previewImageView = [[UIImageView alloc] init];
    self.previewImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.previewImageView];
    self.previewImageView.layer.cornerRadius = 6;
    self.previewImageView.layer.masksToBounds = YES;
    [self.previewImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.equalTo(self);
        make.width.height.mas_equalTo(56);
    }];
    
    self.countLab = [[UILabel alloc] init];
    [self addSubview:self.countLab];
    self.countLab.textAlignment = NSTextAlignmentCenter;
    self.countLab.font = [UIFont systemFontOfSize:10];
    self.countLab.textColor = [UIColor whiteColor];
    self.countLab.backgroundColor = [UIColor hz_getColor:@"2B96FA"];
    [self.countLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.previewImageView.mas_trailing);
        make.centerY.equalTo(self.previewImageView.mas_top);
        make.width.height.mas_equalTo(14);
    }];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    self.countLab.layer.cornerRadius = 7;
    self.countLab.layer.borderWidth = 1.0;
    self.countLab.layer.borderColor = [UIColor whiteColor].CGColor;
    self.countLab.layer.masksToBounds = YES;
}

- (void)updateWithImage:(UIImage *)image count:(NSInteger)count {
    if (count == 0) {
        self.hidden = YES;
    }else {
        self.hidden = NO;
    }
    
    __block UIImage *img = image;
    if (image.size.width > 200) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            img = [image hz_resizeImageToWidth:200];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.previewImageView.image = img;
                self.countLab.text = [NSString stringWithFormat:@"%@",@(count)];
            });
        });
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.previewImageView.image = img;
            self.countLab.text = [NSString stringWithFormat:@"%@",@(count)];
        });
    }
}

@end
