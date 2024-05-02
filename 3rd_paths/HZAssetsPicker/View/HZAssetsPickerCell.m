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
#import "HZAssetsLongPressManager.h"

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
        make.width.height.mas_equalTo(26);
        make.top.equalTo(self.contentView).offset(5);
        make.trailing.equalTo(self.contentView).offset(-5);
    }];
}

- (void)configAsset:(HZAsset *)asset {
    self.asset = asset;
    @weakify(self);
    self.imageView.image = nil;
    [self.asset requestThumbnailWithCompleteBlock:^(UIImage * _Nonnull image) {
        @strongify(self);
        self.imageView.image = image;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }];
    
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
                [[HZAssetsLongPressManager manager] showFromCell:self.imageView asset:self.asset];
            }];
        }];
        
        UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
        [gen prepare];
        [gen impactOccurred];
    }else if (gesture.state == UIGestureRecognizerStateEnded) {
        [[HZAssetsLongPressManager manager] dismiss];
    }
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
        _numLab.font = [UIFont systemFontOfSize:15];
        _numLab.layer.borderColor = [UIColor whiteColor].CGColor;
        _numLab.layer.borderWidth = 2.0;
        _numLab.layer.cornerRadius = 13.0;
        _numLab.layer.masksToBounds = YES;
        _numLab.backgroundColor = [UIColor hz_getColor:@"2B96FA"];
    }
    return _numLab;
}

@end
