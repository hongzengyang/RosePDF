//
//  HZDetectorManager.h
//  PDFConverter
//
//  Created by THS on 2024/4/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HZDetectorManager : NSObject

+ (NSArray *)detectCornersWithImage:(UIImage *)image;

@end

