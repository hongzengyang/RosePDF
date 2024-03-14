//
//  HZPageModel.m
//  RosePDF
//
//  Created by THS on 2024/2/4.
//

#import "HZPageModel.h"
#import <CoreImage/CIFilterBuiltins.h>
#import "HZCommonHeader.h"
#import "HZProjectManager.h"
#import <HZFoundationKit/HZSerializeObject.h>
#import "HZFilterManager.h"

@implementation HZValueModel

HZ_SERIALIZE_CODER_DECODER();
HZ_SERIALIZE_COPY_WITH_ZONE();

@end

@implementation HZFilterModel

HZ_SERIALIZE_CODER_DECODER();
HZ_SERIALIZE_COPY_WITH_ZONE();

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
                @"value" : [HZValueModel class]
             };
}

@end

@implementation HZAdjustModel

HZ_SERIALIZE_CODER_DECODER();
HZ_SERIALIZE_COPY_WITH_ZONE();

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
                @"brightnessValue" : [HZValueModel class],
                @"contrastValue" : [HZValueModel class],
                @"saturationValue" : [HZValueModel class]
             };
}

@end

@interface HZPageModel()

@end

@implementation HZPageModel

@synthesize borderArray = _borderArray;

HZ_SERIALIZE_CODER_DECODER();
HZ_SERIALIZE_COPY_WITH_ZONE();

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"title" : @"title",
             @"border" : @"border",
             @"createTime" : @"createTime",
             @"orientation" : @"orientation",
             @"filter" : @"filter",
             @"adjust" : @"adjust"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
                @"filter" : [HZFilterModel class],
                @"adjust" : [HZAdjustModel class]
             };
}
- (instancetype)init {
    if (self = [super init]) {
        self.filter = [HZFilterManager defaultFilterModel:(HZFilter_none)];
        self.adjust = [HZFilterManager defaultAdjustModel];
    }
    return self;
}

+ (HZPageModel *)readWithPageId:(NSString *)pageId projectId:(NSString *)projectId {
    HZPageModel *pageModel = nil;
    if (pageId.length > 0 && projectId.length > 0) {
        pageModel = [[HZPageModel alloc] init];
        pageModel.identifier = pageId;
        pageModel.projectId = projectId;
        [pageModel readFromDisk];
    }
    return pageModel;
}

- (void)readFromDisk {
    NSString *path = [self configPath];
    NSString *jsonStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    HZPageModel *tmpModel = [HZPageModel yy_modelWithJSON:jsonStr];
    if (tmpModel) {
        self.title = tmpModel.title;
        self.border = tmpModel.border;
        self.createTime = tmpModel.createTime;
        self.orientation = tmpModel.orientation;
        self.filter = tmpModel.filter;
        self.adjust = tmpModel.adjust;
        
        [self borderArray];
    }
}

- (void)saveToDisk {
    NSString *path = [self configPath];
    NSString *jsonStr = [self yy_modelToJSONString];
    NSError *error;
    [jsonStr writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

+ (NSString *)folderPathWithPageId:(NSString *)pageId projectId:(NSString *)projectId {
    NSString *pageFolderPath = nil;
    NSString *projectPath = [HZProjectManager projectPathWithIdentifier:projectId];
    if (projectPath.length > 0 && pageId.length > 0) {
        pageFolderPath = [projectPath stringByAppendingPathComponent:pageId];
    }
    return pageFolderPath;
}

- (NSString *)pageFolderPath {
    return [[self class] folderPathWithPageId:self.identifier projectId:self.projectId];
}

- (NSString *)originPath {
    return [[self pageFolderPath] stringByAppendingPathComponent:@"origin.jpg"];
}
- (NSString *)previewPath {
    return [[self pageFolderPath] stringByAppendingPathComponent:@"preview.jpg"];
}
- (NSString *)resultPath {
    return [[self pageFolderPath] stringByAppendingPathComponent:@"result.jpg"];
}

- (NSString *)configPath {
    return [[self pageFolderPath] stringByAppendingPathComponent:@"page.config"];
}

- (void)processResultFileWithCompleteBlock:(void (^)(UIImage *))completeBlock writeToFile:(BOOL)writeToFile {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *contentImage = [UIImage imageWithContentsOfFile:[self originPath]];
        if (!contentImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(nil);
            });
            return;
        }
        
        if (!contentImage.CIImage) {
            contentImage = [UIImage imageWithCIImage:[CIImage imageWithCGImage:contentImage.CGImage]];
        }
        
        __block CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();
        
        //crop
        if ([self needCrop]) {
            NSArray <NSValue *>*tmpPoints = self.borderArray;
            NSMutableArray <NSValue *>*newPoints = [NSMutableArray array];
            [tmpPoints enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [newPoints addObject:[NSValue valueWithCGPoint:CGPointMake(obj.CGPointValue.x, contentImage.size.height*contentImage.scale - obj.CGPointValue.y)]];
            }];

            CGSize imageSize = CGSizeMake(contentImage.size.width * contentImage.scale, contentImage.size.height * contentImage.scale);

            CGPoint pixel_topLeft = CGPointMake([self.borderArray[0] CGPointValue].x * imageSize.width,imageSize.height - [self.borderArray[0] CGPointValue].y * imageSize.height);
            CGPoint pixel_bottomLeft = CGPointMake([self.borderArray[1] CGPointValue].x * imageSize.width, imageSize.height - [self.borderArray[1] CGPointValue].y * imageSize.height);
            CGPoint pixel_bottomRight = CGPointMake([self.borderArray[2] CGPointValue].x * imageSize.width, imageSize.height - [self.borderArray[2] CGPointValue].y * imageSize.height);
            CGPoint pixel_topRight = CGPointMake([self.borderArray[3] CGPointValue].x * imageSize.width, imageSize.height - [self.borderArray[3] CGPointValue].y * imageSize.height);

            CIImage *tempImage = contentImage.CIImage;

            CIFilter <CIPerspectiveCorrection>*perspectiveFilter = [CIFilter perspectiveCorrectionFilter];
            perspectiveFilter.inputImage = tempImage;
            perspectiveFilter.topLeft = pixel_topLeft;
            perspectiveFilter.bottomLeft = pixel_bottomLeft;
            perspectiveFilter.bottomRight = pixel_bottomRight;
            perspectiveFilter.topRight = pixel_topRight;
            tempImage = perspectiveFilter.outputImage;

            contentImage = [UIImage imageWithCIImage:tempImage];
            
            CFTimeInterval tt = CFAbsoluteTimeGetCurrent();
            NSLog(@"debug--crop duration:%@",@(tt - startTime));
            startTime = tt;
        }
        //rotate
        if (self.orientation != HZPageOrientation_up) {
            UIImageOrientation orientation = UIImageOrientationUp;
            CGAffineTransform transform;
            switch (self.orientation) {
                case HZPageOrientation_up:
                    orientation = UIImageOrientationUp;
                    transform = CGAffineTransformMakeRotation(M_PI_2 * 0);
                    break;
                case HZPageOrientation_left:{
                    orientation = UIImageOrientationLeft;
                    transform = CGAffineTransformMakeRotation(M_PI_2 * 1);
                }
                    break;
                case HZPageOrientation_down:{
                    orientation = UIImageOrientationDown;
                    transform = CGAffineTransformMakeRotation(M_PI_2 * 2);
                }
                    break;
                case HZPageOrientation_right:{
                    orientation = UIImageOrientationRight;
                    transform = CGAffineTransformMakeRotation(M_PI_2 * 3);
                }
                    break;
                default:
                    break;
            }
            // 创建滤镜
            CIFilter *filter = [CIFilter filterWithName:@"CIAffineTransform"];
            // 设置输入图像
            [filter setValue:[contentImage CIImage] forKey:kCIInputImageKey];
            // 设置变换矩阵
            [filter setValue:[NSValue valueWithCGAffineTransform:transform] forKey:@"inputTransform"];
            // 获取滤镜处理后的输出图像
            CIImage *outputImage = [filter outputImage];
            contentImage = [UIImage imageWithCIImage:outputImage];
            
            CFTimeInterval tt = CFAbsoluteTimeGetCurrent();
            NSLog(@"debug--rotate duration:%@",@(tt - startTime));
            startTime = tt;
        }
        
        //filter
        @weakify(self);
        [HZFilterManager makeFilterImageWithImage:contentImage page:self completeBlock:^(UIImage *result ,HZPageModel *page) {
            @strongify(self);
            
            CFTimeInterval tt = CFAbsoluteTimeGetCurrent();
            NSLog(@"debug--filter duration:%@",@(tt - startTime));
            startTime = tt;
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                UIImage *baseCGImage = result;
                
                if (!baseCGImage.CGImage) {
                    UIGraphicsBeginImageContextWithOptions(baseCGImage.size, NO, baseCGImage.scale);
                    [baseCGImage drawAtPoint:CGPointZero];
                    CGImageRef cgImage = UIGraphicsGetImageFromCurrentImageContext().CGImage;
                    UIGraphicsEndImageContext();
                    baseCGImage = [UIImage imageWithCGImage:cgImage];
                }

                if (writeToFile) {
                    [HZProjectManager compressImage:baseCGImage toPath:[self resultPath]];
                    
                    UIImage *previewImage = [baseCGImage hz_resizeImageToWidth:320];
                    [HZProjectManager compressImage:previewImage toPath:[self previewPath]];
                    
                    [self saveToDisk];
                }
                
                CFTimeInterval tt = CFAbsoluteTimeGetCurrent();
                NSLog(@"debug--compress+io:%@",@(tt - startTime));
                startTime = tt;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completeBlock(baseCGImage);
                    CFTimeInterval tt = CFAbsoluteTimeGetCurrent();
                    NSLog(@"debug--block back duration:%@",@(tt - startTime));
                });                
            });
        }];
    });
}

- (void)writeResultFileWithCompleteBlock:(void (^)(UIImage *))completeBlock {
    [self processResultFileWithCompleteBlock:completeBlock writeToFile:YES];
}

- (void)renderResultImageWithCompleteBlock:(void (^)(UIImage *))completeBlock {
    [self processResultFileWithCompleteBlock:completeBlock writeToFile:NO];
}

+ (void)writeResultFileWithPages:(NSArray<HZPageModel *> *)pages completeBlock:(void (^)(void))completeBlock {
    if (pages.count == 0) {
        if (completeBlock) {
            completeBlock();
        }
        return;
    }
    dispatch_queue_t queue = dispatch_queue_create("com.sbpdf.applyFilter", NULL);
    dispatch_async(queue, ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        __block NSInteger callbackCount = 0;
        @weakify(self);
        for (int i = 0; i < pages.count; i++) {
            CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();
//            NSLog(@"debug--开始刷新第%d页page,startTime:%lf",i,startTime);
            HZPageModel *page = pages[i];
            [page writeResultFileWithCompleteBlock:^(UIImage *result) {
                @strongify(self);
                CFTimeInterval endTime = CFAbsoluteTimeGetCurrent();
//                NSLog(@"debug--完成刷新第%d页page,endTime:%lf",i,(endTime - startTime));
                dispatch_semaphore_signal(semaphore);
                callbackCount++;
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    if (callbackCount == pages.count) {
                        if (completeBlock) {
                            completeBlock();
                        }
                    }
                });
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
    });
}

#pragma mark - Setter Getter
- (NSArray<NSValue *> *)borderArray {
    if (_borderArray.count  == 0) {
        if (self.border.length > 0) {
            NSArray <NSString *>*bs = [_border componentsSeparatedByString:@","];
            NSMutableArray *borderArray = [NSMutableArray arrayWithCapacity:4];
            if (bs.count == 8) {
                
                
                for (NSInteger i = 0; i < 4; i++)
                {
                    NSString *xString = bs[i*2];
                    NSString *yString = bs[i*2 + 1];
                    NSString *pointString = [NSString stringWithFormat:@"%@,%@",xString,yString];
                    CGPoint b = CGPointFromString(pointString);
                    NSValue *value = [NSValue valueWithCGPoint:b];
                    [borderArray addObject:value];
                }
                _borderArray = borderArray;
            }
        }else {
            CGPoint leftTop = CGPointMake(0, 0);
            CGPoint leftBottom = CGPointMake(0, 1);
            CGPoint rightBottom = CGPointMake(1, 1);
            CGPoint rightTop = CGPointMake(1, 0);
            _borderArray = @[@(leftTop),@(leftBottom),@(rightBottom),@(rightTop)];
        }
    }
    return _borderArray;
}

- (void)setBorderArray:(NSArray<NSValue *> * _Nullable)borderArray {
    _borderArray = borderArray;
    if (borderArray.count > 0) {
        NSMutableArray <NSString *>*pointArray = [NSMutableArray array];
        [borderArray enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSValue class]]) {
                CGPoint point = obj.CGPointValue;
                [pointArray addObject:NSStringFromCGPoint(point)];
            }
        }];
        self.border = [pointArray componentsJoinedByString:@","];
    }
}

#pragma mark - 工具方法
- (BOOL)needCrop {
    if (self.borderArray.count != 4) {
        return NO;
    }
    
    __block BOOL containNAN = NO;
    __block BOOL croped = NO;
    [self.borderArray enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint point = [obj CGPointValue];
        if (isnan(point.x) || isnan(point.y)) {
            containNAN = YES;
        }else {
            if ((point.x > 0 && point.x < 1) || (point.y > 0 && point.y < 1)) {
                croped = YES;
            }
        }
    }];
    
    if (containNAN) {
        return NO;
    }
    
    if (!croped) {
        return NO;
    }
    
    return YES;
}

@end
