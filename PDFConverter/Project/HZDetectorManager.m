//
//  HZDetectorManager.m
//  PDFConverter
//
//  Created by THS on 2024/4/22.
//

#import "HZDetectorManager.h"
@import CoreImage;

@implementation HZDetectorManager

+ (NSArray *)detectCornersWithImage:(UIImage *)inputImage {
    // 1. 创建 CIImage 对象
    CIImage *ciImage = [[CIImage alloc] initWithImage:inputImage];

    // 2. 创建 CIDetector 对象并设置检测类型
    NSDictionary *options = @{CIDetectorAccuracy: CIDetectorAccuracyHigh}; // 设置检测器的精度
    CIDetector *rectangleDetector = [CIDetector detectorOfType:CIDetectorTypeRectangle context:nil options:options];

    // 3. 获取检测器的特征
    NSArray *features = [rectangleDetector featuresInImage:ciImage];

    // 4. 绘制矩形并返回结果图像
    UIImage *outputImage = drawRectangles(inputImage, features);
    return features;
}

UIImage *drawRectangles(UIImage *image, NSArray *rectangles) {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    [image drawAtPoint:CGPointZero];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetLineWidth(context, 4.0);
    for (CIRectangleFeature *rectangle in rectangles) {
        CGRect cgRect = rectangle.bounds;
        CGContextAddRect(context, cgRect);
    }
    CGContextStrokePath(context);
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

@end
