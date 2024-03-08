//
//  HZCameraUtils.h
//  HZAssetsPicker
//
//  Created by THS on 2024/3/5.
//

#import <Foundation/Foundation.h>

@interface HZCameraUtils : NSObject

+ (void)checkCameraPermissionWithViewController:(UIViewController *)viewController completeBlock:(void(^)(BOOL complete))completeBlock;

@end

