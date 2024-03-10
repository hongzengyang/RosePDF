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
        case HZFilter_enhance:
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
    if (type == HZFilter_enhance) {
        HZValueModel *value = [[HZValueModel alloc] init];
        value.intensity = 1.0;
        value.defaultValue = value.intensity;
        value.min = 0.0;
        value.max = 4.0;
        model.value = value;
    }else if (type == HZFilter_bw) {
        HZValueModel *value = [[HZValueModel alloc] init];
        value.intensity = 0.5;
        value.defaultValue = value.intensity;
        value.min = 0.0;
        value.max = 1.0;
        model.value = value;
    }else if (type == HZFilter_gray) {
        HZValueModel *value = [[HZValueModel alloc] init];
        value.intensity = 0.5;
        value.defaultValue = value.intensity;
        value.min = 0.0;
        value.max = 1.0;
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
//            CGImageRef cgImage = [image CGImage];
//            if (!cgImage) {
//                UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
//                [image drawAtPoint:CGPointZero];
//                cgImage = UIGraphicsGetImageFromCurrentImageContext().CGImage;
//                UIGraphicsEndImageContext();
//            }
//            CIImage *inputImage = [[CIImage alloc] initWithCGImage:cgImage];
//            CIImage *outputImage;
            
            CIImage *inputImage = [image CIImage];
            if (!inputImage) {
                inputImage = [CIImage imageWithCGImage:image.CGImage];
            }
            CIImage *outputImage;
            
            
            if (pageModel.filter.filterType == HZFilter_enhance) {
                outputImage = [self coreImagePreActionWithImage:inputImage];
                
//                CIFilter <CIDocumentEnhancer> *filter = [CIFilter documentEnhancerFilter];
//                filter.inputImage = outputImage;
//                filter.amount = pageModel.filter.value.intensity;
//                outputImage = [filter outputImage];
  
                CIFilter <CIExposureAdjust> *filter = [CIFilter exposureAdjustFilter];
                filter.inputImage = outputImage;
                filter.EV = pageModel.filter.value.intensity;
                outputImage = [filter outputImage];
                
            }else if (pageModel.filter.filterType == HZFilter_bw) {
                outputImage = [self coreImagePreActionWithImage:inputImage];
                
                CIFilter <CIColorMonochrome> *filter = [CIFilter colorMonochromeFilter];
                filter.inputImage = outputImage;
                filter.color = [CIColor colorWithRed:0.0 green:0.0 blue:0.0];
                filter.intensity = pageModel.filter.value.intensity;
                outputImage = [filter outputImage];
                
            }else if (pageModel.filter.filterType == HZFilter_gray) {
                outputImage = [self coreImagePreActionWithImage:inputImage];
                
                CIFilter <CIColorMonochrome> *filter = [CIFilter colorMonochromeFilter];
                filter.inputImage = outputImage;
                filter.color = [CIColor colorWithCGColor:[UIColor grayColor].CGColor];
                filter.intensity = pageModel.filter.value.intensity;
                outputImage = [filter outputImage];
            }else {
                outputImage = inputImage;
            }
            
            if (!manager.colorControlFilter) {
                manager.colorControlFilter = [CIFilter colorControlsFilter];
                NSLog(@"%@,%@,%@",@(manager.colorControlFilter.brightness),@(manager.colorControlFilter.contrast),@(manager.colorControlFilter.saturation));
            }
            manager.colorControlFilter.inputImage = outputImage;
            manager.colorControlFilter.brightness = pageModel.adjust.brightnessValue.intensity;
            manager.colorControlFilter.contrast = pageModel.adjust.contrastValue.intensity;
            manager.colorControlFilter.saturation = pageModel.adjust.saturationValue.intensity;
            outputImage = [manager.colorControlFilter outputImage];
            
//            outputImage = [outputImage imageByApplyingFilter:@"CIColorControls" withInputParameters:@{@"inputBrightness":@(pageModel.adjust.brightnessValue.intensity),@"inputContrast":@(pageModel.adjust.contrastValue.intensity),@"inputSaturation":@(pageModel.adjust.saturationValue.intensity)}];
            
            UIImage *result = [UIImage imageWithCIImage:outputImage];
            
            inputImage = nil;
            outputImage = nil;
            
            if (completeBlock) {
                completeBlock(result,pageModel);
            }
        }
    });
}

+ (CIImage *)coreImagePreActionWithImage:(CIImage *)inputImage {
    //CIExposureAdjust   曝光调节
    //CISharpenLuminance 锐化调节(亮度)
    //CIUnsharpMask      锐化调节(调节边缘和细节)
    CIImage *outputImage;
    {
        CIFilter <CISharpenLuminance> *filter1 = [CIFilter sharpenLuminanceFilter];
        filter1.inputImage = inputImage;
        filter1.radius = 2.5;
        filter1.sharpness = 0.6;
        outputImage = [filter1 outputImage];
        
        CIFilter <CIUnsharpMask> *filter2 = [CIFilter unsharpMaskFilter];
        filter2.inputImage = outputImage;
        filter2.radius = 2.5;
        filter2.intensity = 0.5;
        outputImage = [filter2 outputImage];
    }
    return outputImage;
}

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
        
        if (pageModel.filter.filterType == HZFilter_enhance) {
            if (!manager.sharpenFilter) {
                manager.sharpenFilter = [[GPUImageSharpenFilter alloc] init];
            }
            manager.sharpenFilter.sharpness = pageModel.filter.value.intensity;
            [filters addObject:manager.sharpenFilter];
        }else if (pageModel.filter.filterType == HZFilter_bw) {
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
