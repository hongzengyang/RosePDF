//
//  HZDetectHelper.m
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import "HZDetectHelper.h"

#include <opencv2/core/mat.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/types_c.h>
#include <opencv2/imgcodecs/ios.h>
#include <vector>

#include <array>
#include <memory>

typedef NS_ENUM(NSUInteger, HZCornerPosition) {
    HZCornerPositionTopLeft       = 1,
    HZCornerPositionTopRight      = 2,
    HZCornerPositionBottomLeft    = 3,
    HZCornerPositionBottomRight   = 4,
};

using namespace std;
using namespace cv;

using std::vector;

using std::move;
using std::array;
using std::string;

//using cv::imread;
//using cv::Mat;
//using cv::Point;
//
//using cv::cvtColor;
//using cv::GaussianBlur;
//using cv::Canny;
//using cv::dilate;
//using cv::COLOR_BGR2GRAY;
//using cv::getStructuringElement;
//using cv::getPerspectiveTransform;
//using cv::warpPerspective;
//using cv::findContours;
//using cv::contourArea;
//using cv::arcLength;
//using cv::approxPolyDP;
//using cv::MORPH_RECT;
//using cv::RETR_EXTERNAL;
//using cv::CHAIN_APPROX_SIMPLE;
//using cv::Size;
//using cv::Point2f;
//using cv::Vec4i;
//using cv::Rect;

@implementation HZDetectHelper

+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat {
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
    
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                     // Width
                                        cvMat.rows,                                     // Height
                                        8,                                              // Bits per component
                                        8 * cvMat.elemSize(),                           // Bits per pixel
                                        cvMat.step[0],                                  // Bytes per row
                                        colorSpace,                                     // Colorspace
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,  // Bitmap info flags
                                        provider,                                       // CGDataProviderRef
                                        NULL,                                           // Decode
                                        false,                                          // Should interpolate
                                        kCGRenderingIntentDefault);                     // Intent
    
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return image;
}

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols,rows;
    if  (image.imageOrientation == UIImageOrientationLeft
         || image.imageOrientation == UIImageOrientationRight) {
        cols = image.size.height;
        rows = image.size.width;
    }
    else{
        cols = image.size.width;
        rows = image.size.height;
 
    }
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    
    cv::Mat cvMatTest;
    cv::transpose(cvMat, cvMatTest);
    
    if  (image.imageOrientation == UIImageOrientationLeft
         || image.imageOrientation == UIImageOrientationRight) {
       
    }
    else{
        return cvMat;
       
    }
    cvMat.release();
    
    cv::flip(cvMatTest, cvMatTest, 1);
    
    
    return cvMatTest;
}

+ (cv::Mat)cvMatFromAdjustedUIImage:(UIImage *)image {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    return cvMat;
}

+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image {
    cv::Mat cvMat = [HZDetectHelper cvMatFromUIImage:image];
    cv::Mat grayMat;
    if ( cvMat.channels() == 1 ) {
        grayMat = cvMat;
    }
    else {
        grayMat = cv :: Mat( cvMat.rows,cvMat.cols, CV_8UC1 );
        cv::cvtColor( cvMat, grayMat, CV_BGR2GRAY );
    }
    return grayMat;
}

+ (cv::Mat)cvMatGrayFromAdjustedUIImage:(UIImage *)image {
    cv::Mat cvMat = [HZDetectHelper cvMatFromAdjustedUIImage:image];
    cv::Mat grayMat;
    if ( cvMat.channels() == 1 ) {
        grayMat = cvMat;
    }
    else {
        grayMat = cv :: Mat( cvMat.rows,cvMat.cols, CV_8UC1 );
        cv::cvtColor( cvMat, grayMat, CV_BGR2GRAY );
    }
    return grayMat;
}

#pragma mark - Public

/**
 轮廓提取，并查找轮廓四个顶点
*/
+ (void)asyncDetectQuadCornersWithImage:(UIImage *)image
                             targetSize:(CGSize)targetSize
                      completionHandler:(nonnull void (^)(NSArray<NSValue *> *))completionHandler {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        cv::Mat original = [HZDetectHelper cvMatFromUIImage:image];
        cv::resize(original, original, cvSize(targetSize.width, targetSize.height));
        
        std::vector<std::vector<cv::Point>>squares;
        std::vector<cv::Point> largest_square;
        
        find_squares(original, squares);
        find_largest_square(squares, largest_square);
        
        NSMutableDictionary *sortedPoints = [NSMutableDictionary dictionary];
        if (largest_square.size() == 4) {
            NSMutableArray *points = [NSMutableArray array];
            
            cv::Point point0 = largest_square[0];
            cv::Point point1 = largest_square[1];
            cv::Point point2 = largest_square[2];
            cv::Point point3 = largest_square[3];
            
            std::vector<cv::Point> sort_square;
            
            sort_square.push_back(point0);
            
            if (point1.y <= sort_square[0].y) {
                sort_square.insert(sort_square.begin(), point1);
            }else {
                sort_square.push_back(point1);
            }
            
            if (point2.y <= sort_square[0].y) {
                sort_square.insert(sort_square.begin(), point2);
            }else if (point2.y <= sort_square[1].y) {
                sort_square.insert(sort_square.begin()+1, point2);
            }else {
                sort_square.push_back(point2);
            }
            
            if (point3.y <= sort_square[0].y) {
                sort_square.insert(sort_square.begin(), point3);
            }else if (point3.y <= sort_square[1].y) {
                sort_square.insert(sort_square.begin()+1, point3);
            }else if (point3.y <= sort_square[2].y) {
                sort_square.insert(sort_square.begin()+2, point3);
            }else {
                sort_square.push_back(point3);
            }
            
            cv::Point sort_0 = sort_square[0];
            cv::Point sort_1 = sort_square[1];
            cv::Point sort_2 = sort_square[2];
            cv::Point sort_3 = sort_square[3];
            
            if (sort_0.x < sort_1.x) {
                [sortedPoints setObject:[NSValue valueWithCGPoint:CGPointMake(sort_0.x, sort_0.y)] forKey:@(HZCornerPositionTopLeft)];
                [sortedPoints setObject:[NSValue valueWithCGPoint:CGPointMake(sort_1.x, sort_1.y)] forKey:@(HZCornerPositionTopRight)];
            }else {
                [sortedPoints setObject:[NSValue valueWithCGPoint:CGPointMake(sort_1.x, sort_1.y)] forKey:@(HZCornerPositionTopLeft)];
                [sortedPoints setObject:[NSValue valueWithCGPoint:CGPointMake(sort_0.x, sort_0.y)] forKey:@(HZCornerPositionTopRight)];
            }
            
            if (sort_2.x < sort_3.x) {
                [sortedPoints setObject:[NSValue valueWithCGPoint:CGPointMake(sort_2.x, sort_2.y)] forKey:@(HZCornerPositionBottomLeft)];
                [sortedPoints setObject:[NSValue valueWithCGPoint:CGPointMake(sort_3.x, sort_3.y)] forKey:@(HZCornerPositionBottomRight)];
            }else {
                [sortedPoints setObject:[NSValue valueWithCGPoint:CGPointMake(sort_3.x, sort_3.y)] forKey:@(HZCornerPositionBottomLeft)];
                [sortedPoints setObject:[NSValue valueWithCGPoint:CGPointMake(sort_2.x, sort_2.y)] forKey:@(HZCornerPositionBottomRight)];
            }
            
//            for (int i = 0; i < 4; i++) {
//                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                      [NSValue valueWithCGPoint:CGPointMake(largest_square[i].x, largest_square[i].y)], @"point" , [NSNumber numberWithInt:(largest_square[i].x + largest_square[i].y)], @"value", nil];
//                [points addObject:dict];
//            }
//
//            int min = [[points valueForKeyPath:@"@min.value"] intValue];
//            int max = [[points valueForKeyPath:@"@max.value"] intValue];
//
//            int minIndex = 0;
//            int maxIndex = 0;
//
//            int missingIndexOne = 0;
//            int missingIndexTwo = 0;
//
//            for (int i = 0; i < 4; i++)
//            {
//                NSDictionary *dict = [points objectAtIndex:i];
//
//                if ([[dict objectForKey:@"value"] intValue] == min)
//                {
//                    [sortedPoints setObject:[dict objectForKey:@"point"] forKey:@(HZCornerPositionTopLeft)];
//                    minIndex = i;
//                    continue;
//                }
//
//                if ([[dict objectForKey:@"value"] intValue] == max)
//                {
//                    [sortedPoints setObject:[dict objectForKey:@"point"] forKey:@(HZCornerPositionBottomRight)];
//                    maxIndex = i;
//                    continue;
//                }
//
//                missingIndexOne = i;
//            }
//
//            for (int i = 0; i < 4; i++)
//            {
//                if (missingIndexOne != i && minIndex != i && maxIndex != i)
//                {
//                    missingIndexTwo = i;
//                }
//            }
//
//            if (largest_square[missingIndexOne].x < largest_square[missingIndexTwo].x)
//            {
//                //2nd Point Found
//                [sortedPoints setObject:[[points objectAtIndex:missingIndexOne] objectForKey:@"point"] forKey:@(HZCornerPositionBottomLeft)];
//                [sortedPoints setObject:[[points objectAtIndex:missingIndexTwo] objectForKey:@"point"] forKey:@(HZCornerPositionTopRight)];
//            }
//            else
//            {
//                //4rd Point Found
//                [sortedPoints setObject:[[points objectAtIndex:missingIndexOne] objectForKey:@"point"] forKey:@(HZCornerPositionTopRight)];
//                [sortedPoints setObject:[[points objectAtIndex:missingIndexTwo] objectForKey:@"point"] forKey:@(HZCornerPositionBottomLeft)];
//            }
        }
        original.release();
        
        CGFloat originWidth = targetSize.width;
        CGFloat originHeight = targetSize.height;
        
        CGPoint topLeft = [[sortedPoints objectForKey:@(HZCornerPositionTopLeft)] CGPointValue];
        
        CGPoint bottomLeft = ([[sortedPoints objectForKey:@(HZCornerPositionBottomLeft)] CGPointValue]);
        if (bottomLeft.x == 0 && bottomLeft.y == 0) {
            bottomLeft = CGPointMake(0, originHeight);
        }
        CGPoint topRight = [[sortedPoints objectForKey:@(HZCornerPositionTopRight)] CGPointValue];
        if (topRight.x == 0 && topRight.y == 0) {
            topRight = CGPointMake(originWidth, 0);
        }
        CGPoint bottomRight = [[sortedPoints objectForKey:@(HZCornerPositionBottomRight)] CGPointValue];
        if (bottomRight.x == 0 && bottomRight.y == 0) {
            bottomRight = CGPointMake(originWidth, originHeight);
        }
        
        
        NSValue *v1 = [NSValue valueWithCGPoint:CGPointMake(topLeft.x / originWidth, topLeft.y / originHeight)];
        NSValue *v2 = [NSValue valueWithCGPoint:CGPointMake(bottomLeft.x / originWidth, bottomLeft.y / originHeight)];
        NSValue *v3 = [NSValue valueWithCGPoint:CGPointMake(bottomRight.x / originWidth, bottomRight.y / originHeight)];
        NSValue *v4 = [NSValue valueWithCGPoint:CGPointMake(topRight.x / originWidth, topRight.y / originHeight)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionHandler) {
                completionHandler(@[v1,v2,v3,v4]);
            }
        });
    });
}

/**
 获取纠偏后的图像
 */
+ (void)asyncCropWithImage:(UIImage *)image
              topLeftPoint:(CGPoint)topLeftPoint
             topRightPoint:(CGPoint)topRightPoint
           bottomLeftPoint:(CGPoint)bottomLeftPoint
          bottomRightPoint:(CGPoint)bottomRightPoint
         completionHandler:(void (^)(UIImage *retImage))completionHandler {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!image) {
            NSLog(@"image is nil");
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionHandler) {
                    completionHandler(nil);
                }
            });
            return;
        }
        
        CGFloat w1 = sqrt( pow(bottomRightPoint.x - bottomLeftPoint.x , 2) + pow(bottomRightPoint.x - bottomLeftPoint.x, 2));
        CGFloat w2 = sqrt( pow(topRightPoint.x - topLeftPoint.x , 2) + pow(topRightPoint.x - topLeftPoint.x, 2));
        
        CGFloat h1 = sqrt( pow(topRightPoint.y - bottomRightPoint.y , 2) + pow(topRightPoint.y - bottomRightPoint.y, 2));
        CGFloat h2 = sqrt( pow(topLeftPoint.y - bottomLeftPoint.y , 2) + pow(topLeftPoint.y - bottomLeftPoint.y, 2));
        
        CGFloat maxWidth = (w1 < w2) ? w1 : w2;
        CGFloat maxHeight = (h1 < h2) ? h1 : h2;
        
        cv::Point2f src[4], dst[4];
        src[0].x = topLeftPoint.x;
        src[0].y = topLeftPoint.y;
        src[1].x = topRightPoint.x;
        src[1].y = topRightPoint.y;
        src[2].x = bottomRightPoint.x;
        src[2].y = bottomRightPoint.y;
        src[3].x = bottomLeftPoint.x;
        src[3].y = bottomLeftPoint.y;
        
        dst[0].x = 0;
        dst[0].y = 0;
        dst[1].x = maxWidth - 1;
        dst[1].y = 0;
        dst[2].x = maxWidth - 1;
        dst[2].y = maxHeight - 1;
        dst[3].x = 0;
        dst[3].y = maxHeight - 1;
        
        cv::Mat undistorted = cv::Mat(cvSize(maxWidth,maxHeight), CV_8UC4);
        cv::Mat original = [HZDetectHelper cvMatFromUIImage:image];
        cv::warpPerspective(original, undistorted, cv::getPerspectiveTransform(src, dst), cvSize(maxWidth, maxHeight));
        
        UIImage *ret = [HZDetectHelper UIImageFromCVMat:undistorted];
        if (!ret) {
            ret = image;
        }
        
        original.release();
        undistorted.release();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionHandler) {
                completionHandler(ret);
            }
        });
    });
}

#pragma mark - C 函数

double angle( cv::Point pt1, cv::Point pt2, cv::Point pt0 )
{
    double dx1 = pt1.x - pt0.x;
    double dy1 = pt1.y - pt0.y;
    double dx2 = pt2.x - pt0.x;
    double dy2 = pt2.y - pt0.y;
    return (dx1*dx2 + dy1*dy2)/sqrt((dx1*dx1 + dy1*dy1)*(dx2*dx2 + dy2*dy2) + 1e-10);
}

// http://stackoverflow.com/questions/8667818/opencv-c-obj-c-detecting-a-sheet-of-paper-square-detection
void find_squares(cv::Mat& image, std::vector<std::vector<cv::Point>>&squares)
{
    // blur will enhance edge detection
    cv::Mat blurred(image);
    //    medianBlur(image, blurred, 9);
    GaussianBlur(image, blurred, cvSize(11,11), 0);//change from median blur to gaussian for more accuracy of square detection
    
    cv::Mat gray0(blurred.size(), CV_8U), gray;
    std::vector<std::vector<cv::Point> > contours;
    
    // find squares in every color plane of the image
    for (int c = 0; c < 3; c++)
    {
        int ch[] = {c, 0};
        mixChannels(&blurred, 1, &gray0, 1, ch, 1);
        
        // try several threshold levels
        const int threshold_level = 2;
        for (int l = 0; l < threshold_level; l++)
        {
            // Use Canny instead of zero threshold level!
            // Canny helps to catch squares with gradient shading
            if (l == 0)
            {
                Canny(gray0, gray, 10, 20, 3); //
                //                Canny(gray0, gray, 0, 50, 5);
                
                // Dilate helps to remove potential holes between edge segments
                dilate(gray, gray, cv::Mat(), cv::Point(-1,-1));
            }
            else
            {
                gray = gray0 >= (l+1) * 255 / threshold_level;
            }
            
            // Find contours and store them in a list
            findContours(gray, contours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
            
            // Test contours
            std::vector<cv::Point> approx;
            for (size_t i = 0; i < contours.size(); i++)
            {
                // approximate contour with accuracy proportional
                // to the contour perimeter
                approxPolyDP(cv::Mat(contours[i]), approx, arcLength(cv::Mat(contours[i]), true)*0.02, true);
                
                // Note: absolute value of an area is used because
                // area may be positive or negative - in accordance with the
                // contour orientation
                if (approx.size() == 4 &&
                    fabs(contourArea(cv::Mat(approx))) > 1000 &&
                    isContourConvex(cv::Mat(approx)))
                {
                    double maxCosine = 0;
                    
                    for (int j = 2; j < 5; j++)
                    {
                        double cosine = fabs(angle(approx[j%4], approx[j-2], approx[j-1]));
                        maxCosine = MAX(maxCosine, cosine);
                    }
                    
                    if (maxCosine < 0.3)
                        squares.push_back(approx);
                }
            }
        }
    }
}

void find_largest_square(const std::vector<std::vector<cv::Point> >& squares, std::vector<cv::Point>& biggest_square)
{
    if (!squares.size())
    {
        // no squares detected
        return;
    }
    
    int max_width = 0;
    int max_height = 0;
    size_t max_square_idx = 0;
    
    for (size_t i = 0; i < squares.size(); i++)
    {
        // Convert a set of 4 unordered Points into a meaningful cv::Rect structure.
        cv::Rect rectangle = boundingRect(cv::Mat(squares[i]));
        
        //        cout << "find_largest_square: #" << i << " rectangle x:" << rectangle.x << " y:" << rectangle.y << " " << rectangle.width << "x" << rectangle.height << endl;
        
        // Store the index position of the biggest square found
        if ((rectangle.width >= max_width) && (rectangle.height >= max_height))
        {
            max_width = rectangle.width;
            max_height = rectangle.height;
            max_square_idx = i;
        }
    }
    
    biggest_square = squares[max_square_idx];
}


cv::Mat debugSquares( std::vector<std::vector<cv::Point> > squares, cv::Mat image )
{
    NSLog(@"DEBUG!/?!");
    for ( unsigned int i = 0; i< squares.size(); i++ ) {
        // draw contour
        
        NSLog(@"LOOP!");
        
        cv::drawContours(image, squares, i, cv::Scalar(255,0,0), 1, 8, std::vector<cv::Vec4i>(), 0, cv::Point());
        
        // draw bounding rect
        cv::Rect rect = boundingRect(cv::Mat(squares[i]));
        cv::rectangle(image, rect.tl(), rect.br(), cv::Scalar(0,255,0), 2, 8, 0);
        
        // draw rotated rect
        cv::RotatedRect minRect = minAreaRect(cv::Mat(squares[i]));
        cv::Point2f rect_points[4];
        minRect.points( rect_points );
        for ( int j = 0; j < 4; j++ ) {
            cv::line( image, rect_points[j], rect_points[(j+1)%4], cv::Scalar(0,0,255), 1, 8 ); // blue
        }
    }
    return image;
}

#pragma mark - ------rose method-------
+ (cv::Mat)rose_preProcessing:(cv::Mat)originImage
{
    Mat imgConverter{};

    cvtColor(originImage, imgConverter, COLOR_BGR2GRAY);
    cv::GaussianBlur(imgConverter, imgConverter, cv::Size(5, 5), 3, 0);
    Canny(imgConverter, imgConverter, 25, 25);

    auto kernel = getStructuringElement(MORPH_RECT, cv::Size(5, 5));
    dilate(imgConverter, imgConverter, kernel);

    return imgConverter;
}

+ (array<cv::Point, 4>)rose_getCountours:(cv::Mat)img
{
    vector<vector<cv::Point>> countors{};
    vector<Vec4i> hierarchy{};

    findContours(img, countors, hierarchy, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);

    array<cv::Point, 4> biggestArea{};
    vector<vector<cv::Point>> conPoly(countors.size());
    vector<cv::Rect> boundRect(countors.size());

    double area{}, maxArea{}, peri{};
    int objCor{};

    for (int i = 0; i < countors.size(); i++)
    {
        area = contourArea(countors[i]);

        if (area > 1000.0)
        {
            peri = arcLength(countors[i], true);
            approxPolyDP(countors[i], conPoly[i], 0.02 * peri, true);

            if (area > maxArea && conPoly[i].size() == 4) {
                maxArea = area;
                biggestArea = { conPoly[i][0], conPoly[i][1], conPoly[i][2], conPoly[i][3] };
            }
        }
    }

    return biggestArea;
}

+ (array<cv::Point, 4>)rose_reorder:(array<cv::Point, 4>)points
{
    array<cv::Point, 4> newPoints{};
    vector<int> sumPoints(points.size()), subPoints(points.size());

    for (int i = 0; i < points.size(); i++)
    {
        sumPoints[i] = points[i].x + points[i].y;
        subPoints[i] = points[i].x - points[i].y;
    }
    newPoints[0] = points[std::min_element(sumPoints.begin(), sumPoints.end()) - sumPoints.begin()];
    newPoints[1] = points[std::max_element(subPoints.begin(), subPoints.end()) - subPoints.begin()];
    newPoints[2] = points[std::min_element(subPoints.begin(), subPoints.end()) - subPoints.begin()];
    newPoints[3] = points[std::max_element(sumPoints.begin(), sumPoints.end()) - sumPoints.begin()];

    return newPoints;
}

+ (cv::Mat)rose_warpImg:(array<cv::Point, 4>)points originImg:(cv::Mat)originImage
{
    float w{}, h{};
    w = sqrtf(powf(static_cast<float>(points[1].x - points[0].x), 2.0f)
        + powf(static_cast<float>(points[1].y - points[0].y), 2.0f));
    h = sqrtf(powf(static_cast<float>(points[2].x - points[0].x), 2.0f)
        + powf(static_cast<float>(points[2].y - points[0].y), 2.0f));

    Point2f src[4] = { points[0], points[1], points[2], points[3] };
    Point2f dst[4] = {
        {0.0f, 0.0f},
        {w, 0.0f},
        {0.0f, h},
        {w, h},
    };
    Mat matrix = getPerspectiveTransform(src, dst), imgWarp{};
    warpPerspective(originImage, imgWarp, matrix, cv::Point(w, h));
    return imgWarp;
}

+ (cv::Mat)rose_findDoc:(UIImage *)image {
    cv::Mat origin = [HZDetectHelper cvMatFromUIImage:image];
    cv::Mat cvMat = [HZDetectHelper cvMatFromUIImage:image];
    
    cvMat = [HZDetectHelper rose_warpImg:[HZDetectHelper rose_reorder:[HZDetectHelper rose_getCountours:[HZDetectHelper rose_preProcessing:cvMat]]] originImg:origin];
    
    UIImage *cvtImage = [HZDetectHelper UIImageFromCVMat:cvMat];
    
    return cvMat;
}

@end

