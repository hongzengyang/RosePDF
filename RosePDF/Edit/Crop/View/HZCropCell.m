//
//  HZCropCell.m
//  RosePDF
//
//  Created by THS on 2024/3/6.
//

#import "HZCropCell.h"
#import "HZCommonHeader.h"
#import "HZCropView.h"
@import AVFoundation;

@interface HZCropCell()<HZCropViewDelegate>

@property (nonatomic, strong) HZCropData *cropData;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) HZCropView *cropView;

@end

@implementation HZCropCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configView];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _imageView.image = nil;
    _imageView.transform = CGAffineTransformIdentity;
    
    _cropView.transform = CGAffineTransformIdentity;
}

- (void)configView {
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.imageView];
    
    self.cropView = [[HZCropView alloc] initWithFrame:[self cropViewFrame] insets:UIEdgeInsetsZero];
    self.cropView.delegate = self;
    [self.contentView addSubview:self.cropView];
}

- (void)configWithData:(HZCropData *)data {
    self.cropData = data;
    
    UIImage *image = [UIImage imageWithContentsOfFile:[self.cropData.pageModel originPath]];
    [self.imageView setFrame:CGRectMake(16, 16, self.contentView.width - 32, self.contentView.height - 32)];
    self.imageView.image = image;
    
    if (CGSizeEqualToSize(data.horizontalSize, CGSizeZero)) {
        data.horizontalSize = [self horizonImageInViewSize:image];
    }
    if (CGSizeEqualToSize(data.verticalSize, CGSizeZero)) {
        data.verticalSize = [self verticalImageInViewSize:image];
    }
    if (data.currentOrientation != HZPageOrientation_up) {
        if (CGAffineTransformEqualToTransform(data.transform, CGAffineTransformMake(0, 0, 0, 0, 0, 0))) {
            data.transform = [self getRotateTransform];
        }
        
        self.imageView.transform = data.transform;
    }
    
    
    [self.cropView setFrame:[self cropViewFrame]];
    [self.cropView resetFrame];
    
    CGSize cropViewSize = self.cropView.size;
    __block NSMutableArray *cropViewPoints = [[NSMutableArray alloc] init];
    [data.borders enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint pt = [obj CGPointValue];
        CGFloat x = pt.x * cropViewSize.width;
        CGFloat y = pt.y * cropViewSize.height;
        [cropViewPoints addObject:@(CGPointMake(x, y))];
    }];
    [self.cropView setCornerPoints:cropViewPoints];
    CGFloat pointsScale = [self pointsButtonScale];
    [self.cropView changePointsScale:pointsScale];
    
    if (data.currentOrientation != HZPageOrientation_up) {
        self.cropView.transform = data.transform;
    }
}

#pragma mark - Private
- (CGRect)cropViewFrame {
    return CGRectMake((self.frame.size.width - self.cropData.verticalSize.width)/2.0, (self.frame.size.height-self.cropData.verticalSize.height)/2.0, self.cropData.verticalSize.width, self.cropData.verticalSize.height);
}

- (CGSize)horizonImageInViewSize:(UIImage *)image {
    CGSize imageSize = image.size;
    return AVMakeRectWithAspectRatioInsideRect(CGSizeMake(imageSize.height, imageSize.width), self.imageView.frame).size;
}

- (CGSize)verticalImageInViewSize:(UIImage *)image {
    CGSize imageSize = image.size;
    return AVMakeRectWithAspectRatioInsideRect(imageSize, self.imageView.frame).size;
}

- (CGAffineTransform)getRotateTransform {
    CGFloat angle = 0;
    CGSize scale = CGSizeMake(1.0, 1.0);
    switch (self.cropData.currentOrientation) {
        case HZPageOrientation_up:
            angle = 0;
            break;
        case HZPageOrientation_left:
            angle = -M_PI/2.0;
            scale = CGSizeMake(self.cropData.horizontalSize.width/self.cropData.verticalSize.height, self.cropData.horizontalSize.height/self.cropData.verticalSize.width);
            break;
        case HZPageOrientation_down:
            angle = -M_PI;
            break;
        case HZPageOrientation_right:
            angle = -M_PI*3.0/2.0;
            scale = CGSizeMake(self.cropData.horizontalSize.width/self.cropData.verticalSize.height, self.cropData.horizontalSize.height/self.cropData.verticalSize.width);
            break;
    }
    CGAffineTransform transform = (angle != 0) ? CGAffineTransformMakeRotation(angle) : CGAffineTransformIdentity;
    if (!(scale.width == 1.0 && scale.height == 1.0)) {
        transform = CGAffineTransformScale(transform, scale.width, scale.height);
    }
    return transform;
}

- (CGFloat)pointsButtonScale {
    CGSize scale = CGSizeMake(1.0, 1.0);
    switch (self.cropData.currentOrientation) {
        case HZPageOrientation_left:
        case HZPageOrientation_right:
        {
            scale = CGSizeMake(self.cropData.verticalSize.height/self.cropData.horizontalSize.width, self.cropData.verticalSize.width/self.cropData.horizontalSize.height);
        }
            break;
        case HZPageOrientation_up:
        case HZPageOrientation_down:
            break;
        default:
            break;
    }
    return scale.width;
}

#pragma mark - HZCropViewDelegate
- (void)viewingAtPoint:(CGPoint)viewPoint
{
//    CGPoint pointInCurrentView = [_cropperView convertPoint:viewPoint toView:self.contentView];
//    self.glassView.hidden = NO;
//
//    [self handleClipsWithPoint:pointInCurrentView];
//    [self.glassView viewingWithCenterPoint:pointInCurrentView];
}

- (void)stopViewing {
//    self.glassView.hidden = YES;
//    self.glassView.frame = CGRectMake(GLASS_INSET, GLASS_INSET, GLASS_WIDTH, GLASS_WIDTH);
    NSArray <NSValue *>*points = [self.cropView cornerPoints];
    
    CGSize cropViewSize = self.cropData.verticalSize;
    __block NSMutableArray *percentPoints = [[NSMutableArray alloc] init];
    [points enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint pt = [obj CGPointValue];
        
        CGFloat x = pt.x / cropViewSize.width;
        CGFloat y = pt.y / cropViewSize.height;
        
        [percentPoints addObject:@(CGPointMake(x, y))];
    }];
    self.cropData.borders = [percentPoints copy];
    self.cropData.modified = YES;
//    if (_delegate && [_delegate respondsToSelector:@selector(stopViewingAtPoints:)]) {
//        [_delegate stopViewingAtPoints:points];
//    }
}

- (void)touchsBegan {
//    if (_delegate && [_delegate respondsToSelector:@selector(startCrop)])
//    {
//        [_delegate startCrop];
//    }
}

- (void)touchsCancelled {
//    if (_delegate && [_delegate respondsToSelector:@selector(endCrop)])
//    {
//        [_delegate endCrop];
//    }
}

@end
