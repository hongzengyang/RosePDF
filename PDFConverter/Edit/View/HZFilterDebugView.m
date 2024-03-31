//
//  HZFilterDebugView.m
//  RosePDF
//
//  Created by THS on 2024/3/27.
//

#import "HZFilterDebugView.h"
#import "HZCommonHeader.h"
#import "HZEditFilterSliderView.h"

@interface HZFilterDebugView()
@property (nonatomic, strong) UIImage *inputImage;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) HZEditFilterSliderView *exposureSlider;
@property (nonatomic, strong) HZEditFilterSliderView *documentEnhancerSlider;
@property (nonatomic, strong) HZEditFilterSliderView *unsharpMaskSlider;
@property (nonatomic, strong) HZEditFilterSliderView *saturationSlider;
@property (nonatomic, strong) HZEditFilterSliderView *brightnessSlider;
@property (nonatomic, strong) HZEditFilterSliderView *contrastSlider;
@property (nonatomic, strong) HZEditFilterSliderView *colorThresholdSlider;
@property (nonatomic, strong) HZEditFilterSliderView *gammaSlider;
@property (nonatomic, strong) HZEditFilterSliderView *colorMonochromeSlider;
@property (nonatomic, strong) HZEditFilterSliderView *boxBlurSlider;
@end

@implementation HZFilterDebugView
- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image {
    if (self = [super initWithFrame:frame]) {
        self.inputImage = image;
        [self configView];
    }
    return self;
}

- (void)configView {
    self.backgroundColor = [UIColor whiteColor];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.width / (self.inputImage.size.width / self.inputImage.size.height))];
    self.imageView.image = self.inputImage;
    [self addSubview:self.imageView];
    
    UIButton *closeBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    closeBtn.backgroundColor = [UIColor redColor];
    [self addSubview:closeBtn];
    [closeBtn addTarget:self action:@selector(clickCloseButton) forControlEvents:(UIControlEventTouchUpInside)];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(20);
        make.top.equalTo(self).offset(hz_safeTop + 20);
        make.width.height.mas_equalTo(44);
    }];
    
    @weakify(self);
    self.exposureSlider = [[HZEditFilterSliderView alloc] initWithFrame:CGRectMake(100, self.height - hz_safeBottom - 30, self.width - 120, 30)];
    self.exposureSlider.debugMode = YES;
    [self.exposureSlider updateWithMin:-4 max:4 value:0 defaultValue:0];
    [self addSubview:self.exposureSlider];
    self.exposureSlider.slideEndBlock = ^{
        @strongify(self);
        NSLog(@"exposure = %@",@(self.exposureSlider.value));
        [self refresh];
    };
    [self addSubview:[self labelWithTitle:@"exposure" frame:CGRectMake(20, self.exposureSlider.top, 80, self.exposureSlider.height)]];
    
    self.documentEnhancerSlider = [[HZEditFilterSliderView alloc] initWithFrame:CGRectMake(100, self.height - hz_safeBottom - 30 * 2, self.width - 120, 30)];
    self.documentEnhancerSlider.debugMode = YES;
    [self.documentEnhancerSlider updateWithMin:0 max:10 value:5 defaultValue:5];
    [self addSubview:self.documentEnhancerSlider];
    self.documentEnhancerSlider.slideEndBlock = ^{
        @strongify(self);
        NSLog(@"documentEnhancer = %@",@(self.documentEnhancerSlider.value));
        [self refresh];
    };
    [self addSubview:[self labelWithTitle:@"documentEnhancer" frame:CGRectMake(20, self.documentEnhancerSlider.top, 80, self.documentEnhancerSlider.height)]];
    
    self.unsharpMaskSlider = [[HZEditFilterSliderView alloc] initWithFrame:CGRectMake(100, self.height - hz_safeBottom - 30 * 3, self.width - 120, 30)];
    self.unsharpMaskSlider.debugMode = YES;
    [self.unsharpMaskSlider updateWithMin:0 max:2 value:0.7 defaultValue:0.7];
    [self addSubview:self.unsharpMaskSlider];
    self.unsharpMaskSlider.slideEndBlock = ^{
        @strongify(self);
        NSLog(@"unsharpMask = %@",@(self.unsharpMaskSlider.value));
        [self refresh];
    };
    [self addSubview:[self labelWithTitle:@"unsharpMask" frame:CGRectMake(20, self.unsharpMaskSlider.top, 80, self.unsharpMaskSlider.height)]];
    
    self.saturationSlider = [[HZEditFilterSliderView alloc] initWithFrame:CGRectMake(100, self.height - hz_safeBottom - 30 * 4, self.width - 120, 30)];
    self.saturationSlider.debugMode = YES;
    [self.saturationSlider updateWithMin:0 max:2 value:1.0 defaultValue:1.0];
    [self addSubview:self.saturationSlider];
    self.saturationSlider.slideEndBlock = ^{
        @strongify(self);
        NSLog(@"saturation = %@",@(self.saturationSlider.value));
        [self refresh];
    };
    [self addSubview:[self labelWithTitle:@"saturation" frame:CGRectMake(20, self.saturationSlider.top, 80, self.saturationSlider.height)]];
    
    self.brightnessSlider = [[HZEditFilterSliderView alloc] initWithFrame:CGRectMake(100, self.height - hz_safeBottom - 30 * 5, self.width - 120, 30)];
    self.brightnessSlider.debugMode = YES;
    [self.brightnessSlider updateWithMin:-1 max:1 value:0 defaultValue:0];
    [self addSubview:self.brightnessSlider];
    self.brightnessSlider.slideEndBlock = ^{
        @strongify(self);
        NSLog(@"brightness = %@",@(self.brightnessSlider.value));
        [self refresh];
    };
    [self addSubview:[self labelWithTitle:@"brightness" frame:CGRectMake(20, self.brightnessSlider.top, 80, self.brightnessSlider.height)]];
    
    self.contrastSlider = [[HZEditFilterSliderView alloc] initWithFrame:CGRectMake(100, self.height - hz_safeBottom - 30 * 6, self.width - 120, 30)];
    self.contrastSlider.debugMode = YES;
    [self.contrastSlider updateWithMin:0 max:4 value:1 defaultValue:1];
    [self addSubview:self.contrastSlider];
    self.contrastSlider.slideEndBlock = ^{
        @strongify(self);
        NSLog(@"contrast = %@",@(self.contrastSlider.value));
        [self refresh];
    };
    [self addSubview:[self labelWithTitle:@"contrast" frame:CGRectMake(20, self.contrastSlider.top, 80, self.contrastSlider.height)]];
    
    self.colorThresholdSlider = [[HZEditFilterSliderView alloc] initWithFrame:CGRectMake(100, self.height - hz_safeBottom - 30 * 7, self.width - 120, 30)];
    self.colorThresholdSlider.debugMode = YES;
    [self.colorThresholdSlider updateWithMin:0 max:1 value:0.5 defaultValue:0.5];
    [self addSubview:self.colorThresholdSlider];
    self.colorThresholdSlider.slideEndBlock = ^{
        @strongify(self);
        NSLog(@"colorThreshold = %@",@(self.colorThresholdSlider.value));
        [self refresh];
    };
    [self addSubview:[self labelWithTitle:@"colorThreshold" frame:CGRectMake(20, self.colorThresholdSlider.top, 80, self.colorThresholdSlider.height)]];
    
    self.gammaSlider = [[HZEditFilterSliderView alloc] initWithFrame:CGRectMake(100, self.height - hz_safeBottom - 30 * 8, self.width - 120, 30)];
    self.gammaSlider.debugMode = YES;
    [self.gammaSlider updateWithMin:0.01 max:10 value:1.0 defaultValue:1.0];
    [self addSubview:self.gammaSlider];
    self.gammaSlider.slideEndBlock = ^{
        @strongify(self);
        NSLog(@"gamma = %@",@(self.gammaSlider.value));
        [self refresh];
    };
    [self addSubview:[self labelWithTitle:@"gamma" frame:CGRectMake(20, self.gammaSlider.top, 80, self.gammaSlider.height)]];
    
    self.colorMonochromeSlider = [[HZEditFilterSliderView alloc] initWithFrame:CGRectMake(100, self.height - hz_safeBottom - 30 * 9, self.width - 120, 30)];
    self.colorMonochromeSlider.debugMode = YES;
    [self.colorMonochromeSlider updateWithMin:0 max:1.0 value:1.0 defaultValue:1.0];
    [self addSubview:self.colorMonochromeSlider];
    self.colorMonochromeSlider.slideEndBlock = ^{
        @strongify(self);
        NSLog(@"colorMonochrome = %@",@(self.colorMonochromeSlider.value));
        [self refresh];
    };
    [self addSubview:[self labelWithTitle:@"colorMonochrome" frame:CGRectMake(20, self.colorMonochromeSlider.top, 80, self.colorMonochromeSlider.height)]];
    
    self.boxBlurSlider = [[HZEditFilterSliderView alloc] initWithFrame:CGRectMake(100, self.height - hz_safeBottom - 30 * 10, self.width - 120, 30)];
    self.boxBlurSlider.debugMode = YES;
    [self.boxBlurSlider updateWithMin:0 max:20.0 value:10.0 defaultValue:10.0];
    [self addSubview:self.boxBlurSlider];
    self.boxBlurSlider.slideEndBlock = ^{
        @strongify(self);
        NSLog(@"boxBlur = %@",@(self.boxBlurSlider.value));
        [self refresh];
    };
    [self addSubview:[self labelWithTitle:@"boxBlur" frame:CGRectMake(20, self.boxBlurSlider.top, 80, self.boxBlurSlider.height)]];
}

- (UILabel *)labelWithTitle:(NSString *)title frame:(CGRect)frame {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    [self addSubview:label];
    label.text = title;
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:13];
    return label;
}

- (void)refresh {
    CIImage *inputImage = [CIImage imageWithCGImage:self.inputImage.CGImage];
    CIImage *outputImage = inputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    
    {//baipingheng
        CIFilter *filter = [CIFilter filterWithName:@"CIWhitePointAdjust"];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        [filter setValue:[CIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forKey:kCIInputColorKey];
        outputImage = [filter outputImage];
    }
    
    if (self.exposureSlider.value != self.exposureSlider.defaultValue) {
        CIFilter *filter = [CIFilter filterWithName:@"CIExposureAdjust"];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        [filter setValue:@(self.exposureSlider.value) forKey:kCIInputEVKey];
        outputImage = [filter outputImage];
    }
    
    if (self.unsharpMaskSlider.value != self.unsharpMaskSlider.defaultValue) {
        CIFilter *filter = [CIFilter filterWithName:@"CIUnsharpMask"];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        [filter setValue:@(self.unsharpMaskSlider.value) forKey:kCIInputIntensityKey];
        outputImage = [filter outputImage];
    }
    
    
    if (self.documentEnhancerSlider.value != self.documentEnhancerSlider.defaultValue) {
        CIFilter *filter = [CIFilter filterWithName:@"CIDocumentEnhancer"];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        [filter setValue:@(self.documentEnhancerSlider.value) forKey:kCIInputAmountKey];
        outputImage = [filter outputImage];
    }
    
    if (self.saturationSlider.value != self.saturationSlider.defaultValue || self.brightnessSlider.value != self.brightnessSlider.defaultValue || self.contrastSlider.value != self.contrastSlider.defaultValue) {
        CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        if (self.saturationSlider.value != self.saturationSlider.defaultValue) {
            [filter setValue:@(self.saturationSlider.value) forKey:kCIInputSaturationKey];
        }
        if (self.brightnessSlider.value != self.brightnessSlider.defaultValue) {
            [filter setValue:@(self.brightnessSlider.value) forKey:kCIInputBrightnessKey];
        }
        if (self.contrastSlider.value != self.contrastSlider.defaultValue) {
            [filter setValue:@(self.contrastSlider.value) forKey:kCIInputContrastKey];
        }
        outputImage = [filter outputImage];
    }
    
    if (self.gammaSlider.value != self.gammaSlider.defaultValue) {
        CIFilter *filter = [CIFilter filterWithName:@"CIGammaAdjust"];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        [filter setValue:@(self.gammaSlider.value) forKey:@"inputPower"];
        outputImage = [filter outputImage];
    }
    
    if (self.colorThresholdSlider.value != self.colorThresholdSlider.defaultValue) {
        CIFilter *filter = [CIFilter filterWithName:@"CIColorThreshold"];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        [filter setValue:@(self.colorThresholdSlider.value) forKey:@"inputThreshold"];
        outputImage = [filter outputImage];
    }
    
    
    if (self.colorMonochromeSlider.value != self.colorMonochromeSlider.defaultValue) {
        CIFilter *filter = [CIFilter filterWithName:@"CIColorMonochrome"];
        [filter setValue:[CIColor colorWithCGColor:[UIColor grayColor].CGColor] forKey:kCIInputColorKey];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        [filter setValue:@(self.colorMonochromeSlider.value) forKey:kCIInputIntensityKey];
        outputImage = [filter outputImage];
    }
    
    if (self.boxBlurSlider.value != self.boxBlurSlider.defaultValue) {
        CIFilter *filter = [CIFilter filterWithName:@"CIBoxBlur"];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        [filter setValue:@(self.boxBlurSlider.value) forKey:kCIInputRadiusKey];
        outputImage = [filter outputImage];
    }
    
    //////////////
    CGRect extent = [outputImage extent];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:extent];
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    self.imageView.image = result;
    
    //b&w 调节exposure ->
}

- (void)clickCloseButton {
    [self removeFromSuperview];
}

@end
