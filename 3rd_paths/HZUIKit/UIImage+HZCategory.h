//
//  UIImage+HZCategory.h
//  HZUIKit
//
//  Created by THS on 2024/1/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (HZCategory)

- (NSData *)hz_bitmapData;
- (NSData *)hz_bitmapFileHeaderData;
- (NSData *)hz_bitmapDataWithFileHeader;

/// 根据view生成对应的image
/// @param targetView 目标view
+ (UIImage *)hz_createImageWithView:(UIView *)targetView;

/// 获取指定颜色和尺寸的image
/// @param color 指定的颜色
/// @param size 指定的尺寸
+ (UIImage *)hz_imageWithColor:(UIColor *)color size:(CGSize)size;

/// 修正图片转向
+ (UIImage *)hz_fixOrientation:(UIImage *)aImage;

//+ (UIImage *)hz_resizeGIFData:(NSData *)gifData size:(CGSize)size;

//image顺时针旋转任意弧度(π)  一个200*200的image旋转π/4后，image尺寸仍为200*200，上下左右会截掉
- (UIImage *)hz_shrinkRotateImageWithRadians:(CGFloat)radians;
//image顺时针旋转任意弧度(π)  一个200*200的image旋转π/4后，image尺寸变为288*288，上下左右不会截掉,尺寸变大
- (UIImage *)hz_extendRotateImageWithRadians:(CGFloat)radians;

/// 绘制image至指定尺寸
/// @param width 指定的width height自适应
- (UIImage *)hz_resizeImageToWidth:(CGFloat)width;

/// 绘制image至指定尺寸
/// @param size 指定的size
- (UIImage *)hz_resizeImageToSize:(CGSize)size;

/// 绘制image至指定尺寸
/// @param width 指定的width height自适应
- (UIImage *)hz_resizeImageToWidth:(CGFloat)width scale:(CGFloat)scale;

/**
 Rounds a new image with a given corner size.
 
 @param radius  The radius of each corner oval. Values larger than half the
 rectangle's width or height are clamped appropriately to half
 the width or height.
 */
- (UIImage *)hz_roundCornerImageByRadius:(CGFloat)radius;

/**
 Rounds a new image with a given corner size.
 
 @param radius       The radius of each corner oval. Values larger than half the
 rectangle's width or height are clamped appropriately to
 half the width or height.
 
 @param borderWidth  The inset border line width. Values larger than half the rectangle's
 width or height are clamped appropriately to half the width
 or height.
 
 @param borderColor  The border stroke color. nil means clear color.
 */
- (UIImage *)hz_roundCornerImageByRadius:(CGFloat)radius
                             borderWidth:(CGFloat)borderWidth
                             borderColor:(nullable UIColor *)borderColor;

- (UIImage *)hz_rotateImageWithOrientation:(UIImageOrientation)orientation;

///指定rect裁剪得到新的image rect单位：pixel
- (UIImage *)hz_cropImageWithRect:(CGRect)rect;

@end


NS_ASSUME_NONNULL_END
