//
//  HZFilterManager.m
//  RosePDF
//
//  Created by THS on 2024/2/29.
//

#import "HZFilterManager.h"
#import "HZPageModel.h"
#import <CoreImage/CoreImage.h>
//#import <CoreImage/CIFilterBuiltins.h>
#import <GPUImage/GPUImage.h>

@interface HZFilterManager ()

@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, strong) GPUImagePicture *stillImageSource;

@property (nonatomic, strong) GPUImageSharpenFilter *sharpenFilter;
@property (nonatomic, strong) GPUImageGrayscaleFilter *grayscaleFilter;

@property (nonatomic, strong) GPUImageBrightnessFilter *brightnessFilter;
@property (nonatomic, strong) GPUImageContrastFilter *contrastFilter;
@property (nonatomic, strong) GPUImageSaturationFilter *saturationFilter;
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
        _queue = dispatch_queue_create("com.sbpdf.filterQueue", DISPATCH_QUEUE_SERIAL);;
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
        value.intensity = 0.8;
        value.defaultValue = value.intensity;
        value.min = 0.0;
        value.max = 1.0;
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
    cValue.intensity = 1.5;
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
            NSLog(@"debug--duration = %@,identifier:%@",@(CFAbsoluteTimeGetCurrent() - start),pageModel.identifier);
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(newImg,pageModel);
            });
        }
    });
}

////1.创建基于CPU的CIContext对象
//    self.context = [CIContext contextWithOptions:
//    [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
// forKey:kCIContextUseSoftwareRenderer]];
//
//    //2.创建基于GPU的CIContext对象
//    self.context = [CIContext contextWithOptions: nil];
//
//    //3.创建基于OpenGL优化的CIContext对象，可获得实时性能
//    self.context = [CIContext contextWithEAGLContext:[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2]];
//
//    // 将UIImage转换成CIImage
//    CIImage *ciImage = [[CIImage alloc] initWithImage:[UIImage imageNamed:@"WechatIMG1.jpeg"]];
//    // 创建滤镜
//    CIFilter *filter = [CIFilter filterWithName:_dataSourse[indexPath.row]
//                                  keysAndValues:kCIInputImageKey, ciImage, nil];
//    [filter setDefaults];
//
//    // 获取绘制上下文
//    CIContext *context = [CIContext contextWithOptions:nil];
//    // 渲染并输出CIImage
//    CIImage *outputImage = [filter outputImage];
//    // 创建CGImage句柄
//    CGImageRef cgImage = [self.context createCGImage:outputImage
//                                      fromRect:[outputImage extent]];
//    imageview.image = [UIImage imageWithCGImage:cgImage];
//    // 释放CGImage句柄
//    CGImageRelease(cgImage)；


@end
