//
//  HZAssetsLongPressManager.m
//  HZAssetsPicker
//
//  Created by THS on 2024/3/12.
//

#import "HZAssetsLongPressManager.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <HZUIKit/HZUIKit.h>

@interface HZAssetsLongPressManager()

@property (nonatomic, strong) UIView *fromCell;

@property (nonatomic, strong) UIView *preview;
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
@property (nonatomic, strong) UIImageView *preImageView;
@property (nonatomic, assign) CGRect curFrame;

@end

@implementation HZAssetsLongPressManager
+ (HZAssetsLongPressManager *)manager {
    static dispatch_once_t pred;
    static HZAssetsLongPressManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[HZAssetsLongPressManager alloc] init];
    });
    return sharedInstance;
}

- (void)showFromCell:(UIImageView *)imageView asset:(HZAsset *)asset {
    UIView *preview = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [[UIApplication sharedApplication].keyWindow addSubview:preview];
    self.preview = preview;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = preview.bounds;
    [preview addSubview:blurEffectView];
    blurEffectView.userInteractionEnabled = NO;
    self.blurEffectView = blurEffectView;
    
    self.curFrame = [imageView.superview convertRect:imageView.frame toView:[UIApplication sharedApplication].keyWindow];
    CGRect targetFrame = AVMakeRectWithAspectRatioInsideRect(CGSizeMake(asset.asset.pixelWidth, asset.asset.pixelHeight), CGRectMake(19, 0, preview.frame.size.width - 19 - 19, preview.frame.size.height));
    
    UIImageView *preImageView = [[UIImageView alloc] initWithFrame:self.curFrame];
    [preview addSubview:preImageView];
    preImageView.image = imageView.image;
    self.preImageView = preImageView;
    
    [UIView animateWithDuration:0.2 animations:^{
        preImageView.frame = targetFrame;
    }];
    
    [asset requestHighQualityWithCompleteBlock:^(UIImage * _Nonnull image) {
        preImageView.image = image;
    }];
    
    @weakify(self);
    [preview hz_clickBlock:^{
        @strongify(self);
        [self dismiss];
    }];
}

- (void)dismiss {
    @weakify(self);
    [UIView animateWithDuration:0.2 animations:^{
        self.blurEffectView.alpha = 0.0;
        self.preImageView.alpha = 0.0;
        self.preImageView.frame = self.curFrame;
    } completion:^(BOOL finished) {
        @strongify(self);
        [self.preview removeFromSuperview];
        self.fromCell = nil;
    }];
}

@end
