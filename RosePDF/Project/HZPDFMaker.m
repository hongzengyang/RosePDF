//
//  HZPDFMaker.m
//  RosePDF
//
//  Created by THS on 2024/2/21.
//

#import "HZPDFMaker.h"
#import "HZCommonHeader.h"
@import UIKit;

@implementation HZPDFMaker

+ (void)generatePDFWithProject:(HZProjectModel *)project completeBlock:(void (^)(NSString *))completeBlock {
    NSTimeInterval start = CFAbsoluteTimeGetCurrent();
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *filePath = [project pdfPath];
        NSData *pdfData = [self createPDFWithProject:project];
        if (pdfData) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
            [pdfData writeToFile:filePath atomically:YES];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSTimeInterval end = CFAbsoluteTimeGetCurrent();
            NSLog(@"debug--pdf duration:%@ - size:%@",@(end - start),[[NSFileManager defaultManager] hz_toMorestTwoFloatMBSize:pdfData.length]);
            if (completeBlock) {
                completeBlock(filePath);
            }
        });
    });
    
}

+ (NSData *)createPDFWithProject:(HZProjectModel *)project {
    
    NSMutableArray <UIImage *>*images = [[NSMutableArray alloc] init];
    [project.pageModels enumerateObjectsUsingBlock:^(HZPageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImage *image = [UIImage imageWithContentsOfFile:[obj resultPath]];
        if (image) {
            NSData *data = UIImageJPEGRepresentation(image, [self qualityWith:project.quality]);
            image = [UIImage imageWithData:data];
            [images addObject:image];
        }
    }];
    
    CGFloat marginScale;
    if (project.margin == HZPDFMargin_normal) {
        marginScale = 0.1;
    }else {
        marginScale = 0.0;
    }
    
    NSMutableData *pdfData = nil;
    if (images.count > 0) {
        BOOL isOrigin = (project.pdfSize == HZPDFSize_autoFit);
        if (isOrigin) {
            pdfData = [NSMutableData data];
            CGFloat targetWidth = [images firstObject].size.width;
            CGRect pdfFrame = CGRectMake(0, 0, targetWidth, 0);
            UIGraphicsBeginPDFContextToData(pdfData, pdfFrame, [self documentInfoWithPassword:project.password]);
//            CGContextRef pdfContext = UIGraphicsGetCurrentContext();
            for (NSInteger index = 0; index < images.count; index ++) {
                @autoreleasepool {
                    UIImage *img = images[index];
                    CGSize pageSize = CGSizeMake(targetWidth, targetWidth * (img.size.height / img.size.width));
                    CGFloat x;
                    CGFloat y;
                    CGFloat width;
                    CGFloat height;
                    if (project.margin == HZPDFMargin_none) {
                        x = 0;
                        y = 0;
                        width = pageSize.width;
                        height = pageSize.height;
                    }else {
                        x = pageSize.width * 0.1;
                        y = pageSize.height * 0.1;
                        width = pageSize.width * 0.8;
                        height = pageSize.height * 0.8;
                    }
                    
                    pdfFrame = CGRectMake(0, 0, pageSize.width, pageSize.height);
                    UIGraphicsBeginPDFPageWithInfo(pdfFrame, nil);
                    [img drawInRect:CGRectMake(x, y, width, height)];
                }
            }
            UIGraphicsEndPDFContext();
        }else {
            pdfData = [NSMutableData data];
            CGSize pageSize = [self pageSizeWithoutOrigin:project.pdfSize];
            
            UIEdgeInsets inset = UIEdgeInsetsZero;
            if (project.margin == HZPDFMargin_normal) {
                inset = UIEdgeInsetsMake(pageSize.width * 0.1, pageSize.height * 0.1, pageSize.width * 0.1, pageSize.height * 0.1);
            }
            CGSize contentSize = CGSizeMake(pageSize.width - (inset.left + inset.right), pageSize.height - (inset.top + inset.bottom));
            CGRect pdfFrame = CGRectMake(0, 0, pageSize.width, pageSize.height);
    
            UIGraphicsBeginPDFContextToData(pdfData, pdfFrame, [self documentInfoWithPassword:project.password]);
//            CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    
            for (NSInteger index = 0; index < images.count; index ++) {
                @autoreleasepool {
                    UIImage *img = images[index];
                    CGRect imgFrame = [self drawImageFrameWithContentSize:contentSize insets:inset imageSize:img.size];
    
                    UIGraphicsBeginPDFPageWithInfo(pdfFrame, nil);
                    [img drawInRect:imgFrame];
                }
            }
    
            UIGraphicsEndPDFContext();
        }
    }
    
    return pdfData;
}

+ (CGFloat)qualityWith:(HZPDFQuality)quality {
    CGFloat q = 0.4;
    switch (quality) {
        case HZPDFQuality_100:
            q = 0.9;
            break;
        case HZPDFQuality_75:
            q = 0.75;
            break;
        case HZPDFQuality_50:
            q = 0.5;
            break;
        case HZPDFQuality_25:
            q = 0.4;
            break;
        default:
            break;
    }
    return q;
}

+ (NSMutableDictionary *)documentInfoWithPassword:(NSString *)password {
    NSMutableDictionary *documentInfo = nil;
    if (password.length > 0)
    {
        documentInfo = CFBridgingRelease(CFDictionaryCreateMutable(NULL, 0,
                                                                   &kCFTypeDictionaryKeyCallBacks,
                                                                   &kCFTypeDictionaryValueCallBacks));
        CFDictionarySetValue((__bridge CFMutableDictionaryRef)(documentInfo), kCGPDFContextUserPassword, CFBridgingRetain(password));
        CFDictionarySetValue((__bridge CFMutableDictionaryRef)(documentInfo), kCGPDFContextOwnerPassword, CFBridgingRetain(password));
    }
    return documentInfo;
}

+ (CGSize)pageSizeWithoutOrigin:(HZPDFSize)size {
    CGSize pageSize = CGSizeZero;
    switch (size) {
        case HZPDFSize_A3:
            pageSize = CGSizeMake(842, 1191);
            break;
        case HZPDFSize_A4:
            pageSize = CGSizeMake(595, 842);
            break;
        case HZPDFSize_A5:
            pageSize = CGSizeMake(421, 595);
            break;
        case HZPDFSize_B4:
            pageSize = CGSizeMake(708, 1001);
            break;
        case HZPDFSize_B5:
            pageSize = CGSizeMake(499, 708);
            break;
        case HZPDFSize_Executive:
            pageSize = CGSizeMake(522, 756);
            break;
        case HZPDFSize_Letter:
            pageSize = CGSizeMake(612, 792);
            break;
        case HZPDFSize_Legal:
            pageSize = CGSizeMake(612, 1008);
            break;
        default:
            pageSize = CGSizeMake(595, 842);
            break;
    }
    
    return pageSize;
}

+ (CGRect)drawImageFrameWithContentSize:(CGSize)contentSize insets:(UIEdgeInsets)inset imageSize:(CGSize)imageSize {
    CGSize targetSize = CGSizeZero;
    CGFloat whRatio = imageSize.width/imageSize.height;
    
    targetSize.width = contentSize.width;
    targetSize.height = targetSize.width/whRatio;
    if (targetSize.height > contentSize.height)
    {
        targetSize.height = contentSize.height;
        targetSize.width = targetSize.height*whRatio;
    }
    
    CGRect imageFrame = CGRectMake(inset.left+(contentSize.width-targetSize.width)/2.0,inset.top+(contentSize.height-targetSize.height)/2.0, targetSize.width, targetSize.height);
    return imageFrame;
}

@end
