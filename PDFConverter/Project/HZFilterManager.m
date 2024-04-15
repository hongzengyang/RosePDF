//
//  HZFilterManager.m
//  RosePDF
//
//  Created by THS on 2024/2/29.
//

#import "HZFilterManager.h"
#import "HZPageModel.h"
#import <CoreImage/CoreImage.h>
#import <CoreImage/CIFilterBuiltins.h>
#import <GPUImage/GPUImage.h>

@interface HZFilterManager ()

@property (nonatomic, strong) dispatch_queue_t queue;

//GPUImage
@property (nonatomic, strong) GPUImagePicture *stillImageSource;

@property (nonatomic, strong) GPUImageSharpenFilter *sharpenFilter;
@property (nonatomic, strong) GPUImageGrayscaleFilter *grayscaleFilter;

@property (nonatomic, strong) GPUImageBrightnessFilter *brightnessFilter;
@property (nonatomic, strong) GPUImageContrastFilter *contrastFilter;
@property (nonatomic, strong) GPUImageSaturationFilter *saturationFilter;

//CoreImage
//@property (strong, nonatomic) CIContext *context;
//@property (strong, nonatomic) CIFilter *filter;
@property (strong, nonatomic) CIImage *beginImage;
@property (strong, nonatomic) CIFilter <CIColorControls> *colorControlFilter;
@end

@implementation HZFilterManager

+ (HZFilterManager *)manager {
    static dispatch_once_t pred;
    static HZFilterManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[HZFilterManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _queue = dispatch_queue_create("com.sbpdf.filterQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (NSString *)filterNameWithType:(HZFilterType)type {
    NSString *name;
    switch (type) {
        case HZFilter_none:
            name = NSLocalizedString(@"str_original", nil);
            break;
        case HZFilter_color:
            name = NSLocalizedString(@"str_enhance", nil);
            break;
        case HZFilter_bw:
            name = NSLocalizedString(@"str_bw", nil);
            break;
        case HZFilter_gray:
            name = NSLocalizedString(@"str_gray", nil);
            break;
        default:
            break;
    }
    return name;
}

+ (HZFilterModel *)defaultFilterModel:(HZFilterType)type {
    HZFilterModel *model = [[HZFilterModel alloc] init];
    model.filterType = type;
    if (type == HZFilter_bw) {
        HZValueModel *value = [[HZValueModel alloc] init];
        value.intensity = 0.1;
        value.defaultValue = value.intensity;
        value.min = -1.0;
        value.max = 1.0;
        model.value = value;
    }else if (type == HZFilter_gray) {
        HZValueModel *value = [[HZValueModel alloc] init];
        value.intensity = 0.9;
        value.defaultValue = value.intensity;
        value.min = -1.0;
        value.max = 1.0;
        model.value = value;
    }else if (type == HZFilter_color) {
        HZValueModel *value = [[HZValueModel alloc] init];
        value.intensity = 1.2;
        value.defaultValue = value.intensity;
        value.min = 0.0;
        value.max = 2.0;
        model.value = value;
    }
    
    return model;
}

+ (HZAdjustModel *)defaultAdjustModel {
    HZAdjustModel *adjust = [[HZAdjustModel alloc] init];
    
    HZValueModel *bValue = [[HZValueModel alloc] init];
    bValue.min = -1.0;
    bValue.max = 1.0;
    bValue.intensity = 0.0;
    bValue.defaultValue = bValue.intensity;
    adjust.brightnessValue = bValue;
    
    HZValueModel *cValue = [[HZValueModel alloc] init];
    cValue.min = 1.0;
    cValue.max = 3.0;
    cValue.intensity = 1.0;
    cValue.defaultValue = cValue.intensity;
    adjust.contrastValue = cValue;
    
    HZValueModel *sValue = [[HZValueModel alloc] init];
    sValue.min = 0.0;
    sValue.max = 2.0;
    sValue.intensity = 1.0;
    sValue.defaultValue = sValue.intensity;
    adjust.saturationValue = sValue;
    
    return adjust;
}

+ (void)makeFilterImageWithImage:(UIImage *)image page:(HZPageModel *)pageModel completeBlock:(void (^)(UIImage *, HZPageModel *))completeBlock {
    [self coreImageWithImage:image page:pageModel completeBlock:completeBlock];
//    [self GPUImageWithImage:image page:pageModel completeBlock:completeBlock];
}

+ (void)coreImageWithImage:(UIImage *)image page:(HZPageModel *)pageModel completeBlock:(void (^)(UIImage *, HZPageModel *))completeBlock {
    HZFilterManager *manager = [HZFilterManager manager];
    dispatch_async(manager.queue, ^{
        @autoreleasepool {
            CIImage *inputImage = [image CIImage];
            if (!inputImage) {
                inputImage = [CIImage imageWithCGImage:image.CGImage];
            }
            CIImage *outputImage;
            
            
            CIContext *context = [CIContext contextWithOptions:nil];
            if (pageModel.filter.filterType == HZFilter_bw) {
                outputImage = [self coreImage_BWFilter:inputImage pageModel:pageModel];
            }else if (pageModel.filter.filterType == HZFilter_gray) {
                outputImage = [self coreImage_GrayFilter:inputImage pageModel:pageModel];
            }else if (pageModel.filter.filterType == HZFilter_color) {
                outputImage = [self coreImage_ColorFilter:inputImage pageModel:pageModel];
            }else {
                outputImage = inputImage;
            }
            
            CIFilter *adjustFilter = [CIFilter filterWithName:@"CIColorControls"];
            [adjustFilter setValue:outputImage forKey:kCIInputImageKey];
            [adjustFilter setValue:@(pageModel.adjust.brightnessValue.intensity) forKey:kCIInputBrightnessKey];
            [adjustFilter setValue:@(pageModel.adjust.contrastValue.intensity) forKey:kCIInputContrastKey];
            [adjustFilter setValue:@(pageModel.adjust.saturationValue.intensity) forKey:kCIInputSaturationKey];
            outputImage = [adjustFilter outputImage];
//
            CGRect extent = [outputImage extent];
            CGImageRef cgImage = [context createCGImage:outputImage fromRect:extent];
            UIImage *result = [UIImage imageWithCGImage:cgImage];
            CGImageRelease(cgImage);
            
            
            if (completeBlock) {
                completeBlock(result,pageModel);
            }
        }
    });
}

+ (CIImage *)coreImagePreActionWithImage:(CIImage *)inputImage {
//    return inputImage;
    //CIExposureAdjust   曝光调节
    //CISharpenLuminance 锐化调节(亮度)
    //CIUnsharpMask      锐化调节(调节边缘和细节)
    CIImage *outputImage;
//    {
//        CIFilter <CISharpenLuminance> *filter1 = [CIFilter sharpenLuminanceFilter];
//        filter1.inputImage = inputImage;
//        filter1.radius = 2.5;
//        filter1.sharpness = 0.6;
//        outputImage = [filter1 outputImage];
//
//        CIFilter <CIUnsharpMask> *filter2 = [CIFilter unsharpMaskFilter];
//        filter2.inputImage = outputImage;
//        filter2.radius = 2.5;
//        filter2.intensity = 0.5;
//        outputImage = [filter2 outputImage];
//    }
    {
        CIFilter *filter1 = [CIFilter filterWithName:@"CISharpenLuminance"];
        [filter1 setValue:inputImage forKey:kCIInputImageKey];
        [filter1 setValue:@(2.5) forKey:kCIInputRadiusKey];
        [filter1 setValue:@(0.6) forKey:kCIInputSharpnessKey];
        outputImage = [filter1 outputImage];
        
        CIFilter *filter2 = [CIFilter filterWithName:@"CIUnsharpMask"];
        [filter2 setValue:outputImage forKey:kCIInputImageKey];
        [filter2 setValue:@(2.5) forKey:kCIInputRadiusKey];
        [filter2 setValue:@(0.5) forKey:kCIInputIntensityKey];
        outputImage = [filter2 outputImage];
    }
    return outputImage;
}

+ (CIImage *)coreImage_BWFilter:(CIImage *)inputImage pageModel:(HZPageModel *)pageModel {
    CIImage *outputImage = inputImage;
    {//baipingheng
        CIFilter *filter = [CIFilter filterWithName:@"CIWhitePointAdjust"];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        [filter setValue:[CIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forKey:kCIInputColorKey];
        outputImage = [filter outputImage];
    }
    {
        CIFilter *filter = [CIFilter filterWithName:@"CIExposureAdjust"];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        [filter setValue:@(pageModel.filter.value.intensity) forKey:kCIInputEVKey];
        outputImage = [filter outputImage];
    }
    {
//        CIFilter *filter = [CIFilter filterWithName:@"CIUnsharpMask"];
//        [filter setValue:outputImage forKey:kCIInputImageKey];
//        [filter setValue:@(0.5) forKey:kCIInputIntensityKey];
//        outputImage = [filter outputImage];
    }
    {
        CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        [filter setValue:@(0.3) forKey:kCIInputSaturationKey];
        [filter setValue:@(0.5) forKey:kCIInputBrightnessKey];
        [filter setValue:@(2.7) forKey:kCIInputContrastKey];
        outputImage = [filter outputImage];
    }
    {
        CIFilter *filter = [CIFilter filterWithName:@"CIGammaAdjust"];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        [filter setValue:@(0.9) forKey:@"inputPower"];
        outputImage = [filter outputImage];
    }
    {
        CIFilter *filter = [CIFilter filterWithName:@"CIColorMonochrome"];
        [filter setValue:[CIColor colorWithRed:0.0 green:0.0 blue:0.0] forKey:kCIInputColorKey];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        [filter setValue:@(0.9) forKey:kCIInputIntensityKey];
        outputImage = [filter outputImage];
    }
    return outputImage;
}

+ (CIImage *)coreImage_GrayFilter:(CIImage *)inputImage pageModel:(HZPageModel *)pageModel {
    CIImage *outputImage = inputImage;
    {//baipingheng
        CIFilter *filter = [CIFilter filterWithName:@"CIWhitePointAdjust"];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        [filter setValue:[CIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forKey:kCIInputColorKey];
        outputImage = [filter outputImage];
    }
    {
        CIFilter *filter = [CIFilter filterWithName:@"CIExposureAdjust"];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        [filter setValue:@(pageModel.filter.value.intensity) forKey:kCIInputEVKey];
        outputImage = [filter outputImage];
    }
    {
        CIFilter *filter = [CIFilter filterWithName:@"CIUnsharpMask"];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        [filter setValue:@(2) forKey:kCIInputIntensityKey];
        outputImage = [filter outputImage];
    }
    {
        CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        [filter setValue:@(0.7) forKey:kCIInputSaturationKey];
        [filter setValue:@(-0.1) forKey:kCIInputBrightnessKey];
        [filter setValue:@(0.9) forKey:kCIInputContrastKey];
        outputImage = [filter outputImage];
    }
    {
        CIFilter *filter = [CIFilter filterWithName:@"CIGammaAdjust"];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        [filter setValue:@(0.48) forKey:@"inputPower"];
        outputImage = [filter outputImage];
    }
    {
        CIFilter *filter = [CIFilter filterWithName:@"CIColorMonochrome"];
        [filter setValue:[CIColor colorWithCGColor:[UIColor grayColor].CGColor] forKey:kCIInputColorKey];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        [filter setValue:@(0.93) forKey:kCIInputIntensityKey];
        outputImage = [filter outputImage];
    }
    return outputImage;
}

+ (CIImage *)coreImage_ColorFilter:(CIImage *)inputImage pageModel:(HZPageModel *)pageModel {
    CIImage *outputImage = inputImage;
    {//baipingheng
        CIFilter *filter = [CIFilter filterWithName:@"CIWhitePointAdjust"];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        [filter setValue:[CIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forKey:kCIInputColorKey];
        outputImage = [filter outputImage];
    }
    {
        CIFilter *filter = [CIFilter filterWithName:@"CIExposureAdjust"];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        [filter setValue:@(0.33) forKey:kCIInputEVKey];
        outputImage = [filter outputImage];
    }
    {
        CIFilter *filter = [CIFilter filterWithName:@"CIUnsharpMask"];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        [filter setValue:@(2) forKey:kCIInputIntensityKey];
        outputImage = [filter outputImage];
    }
    {
        CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        [filter setValue:@(pageModel.filter.value.intensity) forKey:kCIInputSaturationKey];
        [filter setValue:@(0.13) forKey:kCIInputBrightnessKey];
        [filter setValue:@(1.3) forKey:kCIInputContrastKey];
        outputImage = [filter outputImage];
    }
    {
        CIFilter *filter = [CIFilter filterWithName:@"CIGammaAdjust"];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        [filter setValue:@(0.43) forKey:@"inputPower"];
        outputImage = [filter outputImage];
    }
//    {
//        CIFilter *filter = [CIFilter filterWithName:@"CIColorMonochrome"];
//        [filter setValue:[CIColor colorWithCGColor:[UIColor grayColor].CGColor] forKey:kCIInputColorKey];
//        [filter setValue:outputImage forKey:kCIInputImageKey];
//        [filter setValue:@(0.93) forKey:kCIInputIntensityKey];
//        outputImage = [filter outputImage];
//    }
    return outputImage;
}


#pragma mark - GPUImage
+ (void)GPUImageWithImage:(UIImage *)image page:(HZPageModel *)pageModel completeBlock:(void (^)(UIImage *, HZPageModel *))completeBlock {
    NSTimeInterval start = CFAbsoluteTimeGetCurrent();
    
    HZFilterManager *manager = [HZFilterManager manager];
    __block UIImage *newImg;
    dispatch_async(manager.queue, ^{
        [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
        [manager.stillImageSource removeAllTargets];
        manager.stillImageSource = nil;
        manager.stillImageSource = [[GPUImagePicture alloc] initWithImage:image];
        

        NSMutableArray <GPUImageFilter *>*filters = [[NSMutableArray alloc] init];
        
        if (pageModel.filter.filterType == HZFilter_bw) {
            if (!manager.sharpenFilter) {
                manager.sharpenFilter = [[GPUImageSharpenFilter alloc] init];
            }
            manager.sharpenFilter.sharpness = pageModel.filter.value.intensity;
            [filters addObject:manager.sharpenFilter];
        }else if (pageModel.filter.filterType == HZFilter_gray) {
            if (!manager.grayscaleFilter) {
                manager.grayscaleFilter = [[GPUImageGrayscaleFilter alloc] init];
            }
            [filters addObject:manager.grayscaleFilter];
        }else if (pageModel.filter.filterType == HZFilter_color) {
            if (!manager.sharpenFilter) {
                manager.sharpenFilter = [[GPUImageSharpenFilter alloc] init];
            }
            manager.sharpenFilter.sharpness = pageModel.filter.value.intensity;
            [filters addObject:manager.sharpenFilter];
        }else {
            
        }
        

        if (!manager.brightnessFilter) {
            manager.brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
        }
        manager.brightnessFilter.brightness = pageModel.adjust.brightnessValue.intensity;
        [filters addObject:manager.brightnessFilter];
        
        if (!manager.contrastFilter) {
            manager.contrastFilter = [[GPUImageContrastFilter alloc] init];
        }
        manager.contrastFilter.contrast = pageModel.adjust.contrastValue.intensity;
        [filters addObject:manager.contrastFilter];
        
        if (!manager.saturationFilter) {
            manager.saturationFilter = [[GPUImageSaturationFilter alloc] init];
        }
        manager.saturationFilter.saturation = pageModel.adjust.saturationValue.intensity;
        [filters addObject:manager.saturationFilter];
        
        
        __block GPUImageFilter *prevFilter;
        [filters enumerateObjectsUsingBlock:^(GPUImageFilter * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                [manager.stillImageSource addTarget:obj];
            }else {
                [prevFilter addTarget:obj];
            }
            
            prevFilter = obj;
        }];
        
        [prevFilter useNextFrameForImageCapture];
        [manager.stillImageSource processImage];
        newImg = [prevFilter imageFromCurrentFramebuffer];
        
        
        
        if (completeBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(newImg,pageModel);
            });
        }
    });
}


@end
