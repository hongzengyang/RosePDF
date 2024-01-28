//
//  UIImage+HZCategory.m
//  HZUIKit
//
//  Created by THS on 2024/1/25.
//

#import "UIImage+HZCategory.h"
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>

# pragma pack(push, 1)
typedef struct s_bitmap_header
{
    // Bitmap file header
    UInt16 fileType;
    UInt32 fileSize;
    UInt16 reserved1;
    UInt16 reserved2;
    UInt32 bitmapOffset;
    
    // DIB Header
    UInt32 headerSize;
    UInt32 width;
    UInt32 height;
    UInt16 colorPlanes;
    UInt16 bitsPerPixel;
    UInt32 compression;
    UInt32 bitmapSize;
    UInt32 horizontalResolution;
    UInt32 verticalResolution;
    UInt32 colorsUsed;
    UInt32 colorsImportant;
} t_bitmap_header;
#pragma pack(pop)

@implementation UIImage (HZCategory)
- (NSData *)hz_bitmapData {
    NSData          *bitmapData = nil;
    CGImageRef      image = self.CGImage;
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    UInt8           *rawData;
    
    size_t bitsPerPixel = 32;
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
    
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    
    size_t bytesPerRow = width * bytesPerPixel;
    size_t bufferLength = bytesPerRow * height;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace)
    {
        // Allocate memory for raw image data
        rawData = (UInt8 *)calloc(bufferLength, sizeof(UInt8));
        NSLog(@"---%lu", sizeof(rawData));
        if (rawData)
        {
            CGBitmapInfo bitmapInfo = kCGImageByteOrder32Little | kCGImageAlphaPremultipliedFirst;
            context = CGBitmapContextCreate(rawData,
                                            width,
                                            height,
                                            bitsPerComponent,
                                            bytesPerRow,
                                            colorSpace,
                                            bitmapInfo);
            
            if (context)
            {
                CGRect rect = CGRectMake(0, 0, width, height);
                
                CGContextTranslateCTM(context, 0, height);
                CGContextScaleCTM(context, 1.0, -1.0);
                CGContextDrawImage(context, rect, image);
                
                bitmapData = [NSData dataWithBytes:rawData length:bufferLength];
                
                CGContextRelease(context);
            }
            
            free(rawData);
        }
        
        CGColorSpaceRelease(colorSpace);
    }
    
    return bitmapData;
}

- (NSData *)hz_bitmapFileHeaderData {
    CGImageRef image = self.CGImage;
    UInt32     width = (UInt32)CGImageGetWidth(image);
    UInt32     height = (UInt32)CGImageGetHeight(image);
    
    t_bitmap_header header;
    header.fileType = 0x4D42;
    header.fileSize = (height * width * 3) + 54;
    header.reserved1 = 0x0000;
    header.reserved2 = 0x0000;
    header.bitmapOffset = 0x00000036;
    header.headerSize = 0x00000028;
    header.width = width;
    header.height = height;
    header.colorPlanes = 0x0001;
    header.bitsPerPixel = 0x0018;
    header.compression = 0x00000000;
    header.bitmapSize = width * height * 3;
    header.horizontalResolution = 0x00000000;
    header.verticalResolution = 0x00000000;
    header.colorsUsed = 0x00000000;
    header.colorsImportant = 0x00000000;
    
    return [NSData dataWithBytes:&header length:sizeof(t_bitmap_header)];
}

- (NSData *)hz_bitmapDataWithFileHeader
{
    NSMutableData *data = [NSMutableData dataWithData:[self hz_bitmapFileHeaderData]];
    [data appendData:[self hz_bitmapData]];
    
    return [NSData dataWithData:data];
}



+ (UIImage *)hz_createImageWithView:(UIView *)targetView {
    UIGraphicsBeginImageContextWithOptions(targetView.bounds.size, NO, [UIScreen mainScreen].scale);
    [targetView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)hz_imageWithColor:(UIColor *)color
                           size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/// 修正图片转向
+ (UIImage *)hz_fixOrientation:(UIImage *)aImage {
    // No-op if the orientation is already correct
        if (aImage.imageOrientation == UIImageOrientationUp)
            return aImage;
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        CGAffineTransform transform = CGAffineTransformIdentity;
        
        switch (aImage.imageOrientation) {
            case UIImageOrientationDown:
            case UIImageOrientationDownMirrored:
                transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
                transform = CGAffineTransformRotate(transform, M_PI);
                break;
                
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
                transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
                transform = CGAffineTransformRotate(transform, M_PI_2);
                break;
                
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
                transform = CGAffineTransformRotate(transform, -M_PI_2);
                break;
            default:
                break;
        }
        
        switch (aImage.imageOrientation) {
            case UIImageOrientationUpMirrored:
            case UIImageOrientationDownMirrored:
                transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
                transform = CGAffineTransformScale(transform, -1, 1);
                break;
                
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRightMirrored:
                transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
                transform = CGAffineTransformScale(transform, -1, 1);
                break;
            default:
                break;
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                                 CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                                 CGImageGetColorSpace(aImage.CGImage),
                                                 CGImageGetBitmapInfo(aImage.CGImage));
        CGContextConcatCTM(ctx, transform);
        switch (aImage.imageOrientation) {
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                // Grr...
                CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
                break;
                
            default:
                CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
                break;
        }
        
        // And now we just create a new UIImage from the drawing context
        CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
        UIImage *img = [UIImage imageWithCGImage:cgimg];
        CGContextRelease(ctx);
        CGImageRelease(cgimg);
        return img;
}

//+ (UIImage *)hz_resizeGIFData:(NSData *)data
//                          size:(CGSize)size {
//    SDAnimatedImage *animatedImage = [[SDAnimatedImage alloc] initWithData:data];
//    NSMutableArray<SDImageFrame *> *frames = [NSMutableArray array];
//    for (size_t i = 0; i < animatedImage.animatedImageFrameCount; i++) {
//        UIImage *image = [animatedImage animatedImageFrameAtIndex:i];
//        image = [image hz_resizeImageToSize:size];
//        NSTimeInterval duration = [animatedImage animatedImageDurationAtIndex:i];
//        SDImageFrame *frame = [SDImageFrame frameWithImage:image
//                                                  duration:duration];
//        [frames addObject:frame];
//    }
//    UIImage *uiAnimatedImage = [SDImageCoderHelper animatedImageWithFrames:frames];
//    return uiAnimatedImage;
//}

- (UIImage *)hz_shrinkRotateImageWithRadians:(CGFloat)angleInRadians {
    // 1. image --> context
        size_t width = (size_t)(self.size.width * self.scale);
        size_t height = (size_t)(self.size.height * self.scale);

        size_t bytesPerRow = width * 4;                        // 每行图片字节数
        CGImageAlphaInfo alphaInfo = kCGImageAlphaPremultipliedFirst;      // alpha
        
        // 配置上下文
        CGContextRef bmContext = CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrderDefault | alphaInfo);
        
        if (!bmContext) {
            return nil;
        }
        
        CGContextDrawImage(bmContext, CGRectMake(0, 0, width, height), self.CGImage);
        
        
        // 2. 旋转
        UInt8 * data = (UInt8 *)CGBitmapContextGetData(bmContext);
        
        // 需要引入 #import <Accelerate/Accelerate.h>  解释这个类干什么用的
        vImage_Buffer src = {data,height,width,bytesPerRow};
        vImage_Buffer dest = {data,height,width,bytesPerRow};
        Pixel_8888 bgColor = {0,0,0,0};
        vImageRotate_ARGB8888(&src, &dest, NULL, -angleInRadians, bgColor, kvImageBackgroundColorFill);
        

        // 3. context --> UIImage
        CGImageRef rotateImageRef = CGBitmapContextCreateImage(bmContext);
        UIImage * rotateImage = [UIImage imageWithCGImage:rotateImageRef scale:self.scale orientation:self.imageOrientation];
        

        CGContextRelease(bmContext);
        CGImageRelease(rotateImageRef);
        
        
        return rotateImage;
}

- (UIImage *)hz_extendRotateImageWithRadians:(CGFloat)angleInRadians {
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(angleInRadians);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, angleInRadians);
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

- (UIImage *)hz_resizeImageToWidth:(CGFloat)width {
    return [self hz_resizeImageToWidth:width scale:self.scale];
}

- (UIImage *)hz_resizeImageToWidth:(CGFloat)width scale:(CGFloat)scale {
    if (width <= 0) return nil;
    if (self.size.width <= 0) return nil;
    if (self.size.height <= 0) return nil;
    
    CGSize targetSize = CGSizeMake(width, width * self.size.height / self.size.width);
    
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, scale);
    [self drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)hz_resizeImageToSize:(CGSize)size {
    if (size.width <= 0) return nil;
    if (self.size.width <= 0) return nil;
    if (self.size.height <= 0) return nil;
    
    CGSize targetSize = size;
    
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, self.scale);
    [self drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)hz_roundCornerImageByRadius:(CGFloat)radius {
    return [self hz_roundCornerImageByRadius:radius
                                  borderWidth:0
                                  borderColor:nil];
}

- (UIImage *)hz_roundCornerImageByRadius:(CGFloat)radius
                              borderWidth:(CGFloat)borderWidth
                              borderColor:(nullable UIColor *)borderColor {
    return [self hz_roundCornerImageByRadius:radius
                                      corners:UIRectCornerAllCorners
                                  borderWidth:borderWidth
                                  borderColor:borderColor
                               borderLineJoin:kCGLineJoinMiter];
}

- (UIImage *)hz_roundCornerImageByRadius:(CGFloat)radius
                                  corners:(UIRectCorner)corners
                              borderWidth:(CGFloat)borderWidth
                              borderColor:(nullable UIColor *)borderColor
                           borderLineJoin:(CGLineJoin)borderLineJoin {

    if (corners != UIRectCornerAllCorners) {
        UIRectCorner tmp = 0;
        if (corners & UIRectCornerTopLeft) tmp |= UIRectCornerBottomLeft;
        if (corners & UIRectCornerTopRight) tmp |= UIRectCornerBottomRight;
        if (corners & UIRectCornerBottomLeft) tmp |= UIRectCornerTopLeft;
        if (corners & UIRectCornerBottomRight) tmp |= UIRectCornerTopRight;
        corners = tmp;
    }

    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -rect.size.height);

    CGFloat minSize = MIN(self.size.width, self.size.height);
    if (borderWidth < minSize / 2) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, borderWidth, borderWidth)
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(radius, borderWidth)];
        [path closePath];

        CGContextSaveGState(context);
        [path addClip];
        CGContextDrawImage(context, rect, self.CGImage);
        CGContextRestoreGState(context);
    }

    if (borderColor && borderWidth < minSize / 2 && borderWidth > 0) {
        CGFloat strokeInset = (floor(borderWidth * self.scale) + 0.5) / self.scale;
        CGRect strokeRect = CGRectInset(rect, strokeInset, strokeInset);
        CGFloat strokeRadius = radius > self.scale / 2 ? radius - self.scale / 2 : 0;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:strokeRect
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(strokeRadius, borderWidth)];
        [path closePath];

        path.lineWidth = borderWidth;
        path.lineJoinStyle = borderLineJoin;
        [borderColor setStroke];
        [path stroke];
    }

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)hz_rotateImageWithOrientation:(UIImageOrientation)orientation {
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;

    switch (orientation) {
        case UIImageOrientationLeft:rotate = M_PI_2;
            rect = CGRectMake(0, 0, self.size.height, self.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width / rect.size.height;
            scaleX = rect.size.height / rect.size.width;
            break;
        case UIImageOrientationRight:rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, self.size.height, self.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width / rect.size.height;
            scaleX = rect.size.height / rect.size.width;
            break;
        case UIImageOrientationDown:rotate = M_PI;
            rect = CGRectMake(0, 0, self.size.width, self.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:rotate = 0.0;
            rect = CGRectMake(0, 0, self.size.width, self.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }

    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);

    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), self.CGImage);

    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();

    return newPic;
}

- (UIImage *)hz_cropImageWithRect:(CGRect)cutArea {
    // 图片处理对象
    CGImageRef imageRef = self.CGImage;
    // 裁剪后的图片
    CGImageRef cgImage = CGImageCreateWithImageInRect(imageRef, cutArea);
    UIImage *cutImage = [[UIImage alloc] initWithCGImage:cgImage scale:self.scale orientation:(UIImageOrientationUp)];
    return cutImage;
}

@end

