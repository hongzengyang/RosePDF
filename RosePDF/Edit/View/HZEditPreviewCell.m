//
//  HZEditPreviewCell.m
//  RosePDF
//
//  Created by THS on 2024/2/19.
//

#import "HZEditPreviewCell.h"
#import "HZCommonHeader.h"
#import "HZFilterManager.h"
@import AVFoundation;

@interface HZEditPreviewCell()<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) HZPageModel *pageModel;

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *pageImageView;

@end

@implementation HZEditPreviewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    
    }
    return self;
}

- (void)configCell {
    if (!self.containerView) {
        self.containerView = [[UIView alloc] init];
        [self.contentView addSubview:self.containerView];
    }
    [self.containerView setFrame:CGRectMake(0, 0, ScreenWidth, self.contentView.height)];
    
    if (!self.scrollView) {
        self.scrollView = [[UIScrollView alloc] init];
        [self.containerView addSubview:self.scrollView];
        
        // 添加双击手势
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        [self.scrollView addGestureRecognizer:doubleTapGesture];
    }
    [self.scrollView setFrame:self.containerView.bounds];
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.bounces = YES;
    self.scrollView.maximumZoomScale = 3.0f;
    self.scrollView.minimumZoomScale = 1.0f;
    self.scrollView.zoomScale = 1.0;
    self.scrollView.delegate = self;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.clipsToBounds = YES;
    
    if (!self.pageImageView) {
        self.pageImageView = [[UIImageView alloc] init];
        [self.scrollView addSubview:self.pageImageView];
    }
    self.pageImageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else {
        CGPoint location = [gesture locationInView:self.pageImageView];
        CGRect rectToZoomTo = CGRectMake(location.x, location.y, 1, 1);
        [self.scrollView zoomToRect:rectToZoomTo animated:YES];
    }
}

- (void)configWithModel:(HZPageModel *)pageModel filterMode:(BOOL)filterMode {
    self.pageModel = pageModel;
    
    [self configCell];
    
    @weakify(self);
    if (filterMode) {
        [pageModel renderResultImageWithCompleteBlock:^(UIImage *image) {
            @strongify(self);
            if ([pageModel.identifier isEqualToString:self.pageModel.identifier]) {
                [self displayPreviewWithImage:image];
            }
        }];
    }else {
        [self getDisplayImageWithCompleteBlock:^(UIImage *image) {
            @strongify(self);
            [self displayPreviewWithImage:image];
        }];
    }
    
}

- (void)renderPreviewImage {
    @weakify(self);
    [self.pageModel renderResultImageWithCompleteBlock:^(UIImage *image) {
        @strongify(self);
        [self displayPreviewWithImage:image];
    }];
}

- (void)displayPreviewWithImage:(UIImage *)image {

    CGRect rect = AVMakeRectWithAspectRatioInsideRect(CGSizeMake(image.size.width, image.size.height), self.scrollView.bounds);
    if (!isnan(rect.origin.x) && !isnan(rect.origin.y) && !isnan(rect.size.width) && !isnan(rect.size.height)) {
        self.pageImageView.frame = rect;
    }else{
        self.pageImageView.frame = self.contentView.bounds;
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    self.pageImageView.hidden = image ? NO: YES;
    self.pageImageView.image = image;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)resetZoom {
    if (self.scrollView.zoomScale != self.scrollView.minimumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
}

- (void)getDisplayImageWithCompleteBlock:(void(^)(UIImage *image))completeBlock {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *image = [UIImage imageWithContentsOfFile:[self.pageModel resultPath]];
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(image);
        });
    });

}

//代理方法，告诉ScrollView要缩放的是哪个视图
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.pageImageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat scrollW = CGRectGetWidth(scrollView.frame);
    CGFloat scrollH = CGRectGetHeight(scrollView.frame);

    CGSize contentSize = scrollView.contentSize;
    CGFloat offsetX = scrollW > contentSize.width ? (scrollW - contentSize.width) * 0.5 : 0;
    CGFloat offsetY = scrollH > contentSize.height ? (scrollH - contentSize.height) * 0.5 : 0;

    CGFloat centerX = contentSize.width * 0.5 + offsetX;
    CGFloat centerY = contentSize.height * 0.5 + offsetY;

    self.pageImageView.center = CGPointMake(centerX, centerY);
}

@end
