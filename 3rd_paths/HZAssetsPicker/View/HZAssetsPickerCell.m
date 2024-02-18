//
//  HZAssetsPickerCell.m
//  HZAssetsPicker
//
//  Created by THS on 2024/2/7.
//

#import "HZAssetsPickerCell.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <HZUIKit/HZUIKit.h>

@interface HZAssetsPickerCell()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *numLab;

@property (nonatomic, strong) HZAsset *asset;

@property (nonatomic, copy) void(^LongPressBlock)(void);

@end

@implementation HZAssetsPickerCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configView];
        
        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] init];
        [gesture addTarget:self action:@selector(longPressGesture:)];
        [self.contentView addGestureRecognizer:gesture];
    }
    return self;
}

- (void)configView {
    [self.contentView addSubview:self.imageView];
    self.contentView.layer.masksToBounds = YES;
    
    [self.contentView addSubview:self.numLab];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.numLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(14);
        make.top.equalTo(self.contentView).offset(4);
        make.trailing.equalTo(self.contentView).offset(-4);
    }];
}

- (void)configAsset:(HZAsset *)asset {
    self.asset = asset;
    @weakify(self);
    if (asset.isCameraEntrance) {
        self.imageView.image = [UIImage imageNamed:@"rose_camera_enter"];
        self.imageView.contentMode = UIViewContentModeCenter;
    }else {
        self.imageView.image = nil;
        [self.asset requestThumbnailWithCompleteBlock:^(UIImage * _Nonnull image) {
            @strongify(self);
            self.imageView.image = image;
            self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        }];
    }
    
    [[RACObserve(self.asset, index) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if (self.asset.index > 0) {
            self.numLab.text = [NSString stringWithFormat:@"%ld",self.asset.index];
            self.numLab.hidden = NO;
        }else {
            self.numLab.hidden = YES;
        }
    }];
    
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (void)configLongPressGesture:(void (^)(void))gestureBlock {
    self.LongPressBlock = gestureBlock;
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)gesture {
    if (self.LongPressBlock) {
        self.LongPressBlock();
    }

    if (gesture.state == UIGestureRecognizerStateBegan) {
        [UIView animateWithDuration:0.1 animations:^{
            self.transform = CGAffineTransformMakeScale(0.9, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                self.transform = CGAffineTransformMakeScale(1.0, 1.0);
            } completion:^(BOOL finished) {
                [self showPreview];
            }];
        }];
        
        UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
        [gen prepare];
        [gen impactOccurred];
    }
}

- (void)showPreview {
    UIView *preview = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [[UIApplication sharedApplication].keyWindow addSubview:preview];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = preview.bounds;
    [preview addSubview:blurEffectView];
    blurEffectView.userInteractionEnabled = NO;
    
    CGRect curFrame = [self.contentView convertRect:self.imageView.frame toView:[UIApplication sharedApplication].keyWindow];
    CGRect targetFrame = AVMakeRectWithAspectRatioInsideRect(CGSizeMake(self.asset.asset.pixelWidth, self.asset.asset.pixelHeight), CGRectMake(19, 0, preview.width - 19 - 19, preview.height));
    
    UIImageView *preImageView = [[UIImageView alloc] initWithFrame:curFrame];
    [preview addSubview:preImageView];
    preImageView.image = self.imageView.image;
    
    [UIView animateWithDuration:0.2 animations:^{
        preImageView.frame = targetFrame;
    }];
    
    [self.asset requestHighQualityWithCompleteBlock:^(UIImage * _Nonnull image) {
        preImageView.image = image;
    }];
    
    
    @weakify(preview);
    [preview hz_clickBlock:^{
        @strongify(preview);
        [UIView animateWithDuration:0.2 animations:^{
            blurEffectView.alpha = 0.0;
            preImageView.alpha = 0.0;
            preImageView.frame = curFrame;
        } completion:^(BOOL finished) {
            [preview removeFromSuperview];
        }];
    }];
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor hz_getColor:@"E4E3EB"];
    }
    return _imageView;
}

- (UILabel *)numLab {
    if (!_numLab) {
        _numLab = [[UILabel alloc] init];
        _numLab.textAlignment = NSTextAlignmentCenter;
        _numLab.textColor = [UIColor whiteColor];
        _numLab.font = [UIFont systemFontOfSize:10];
        _numLab.layer.borderColor = [UIColor whiteColor].CGColor;
        _numLab.layer.borderWidth = 1.0;
        _numLab.layer.cornerRadius = 7.0;
        _numLab.layer.masksToBounds = YES;
        _numLab.backgroundColor = [UIColor hz_getColor:@"2B96FA"];
    }
    return _numLab;
}

@end
