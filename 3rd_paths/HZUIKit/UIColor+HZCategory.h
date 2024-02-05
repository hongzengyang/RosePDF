//
//  UIColor+HZCategory.h
//  HZUIKit
//
//  Created by THS on 2024/2/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (HZCategory)
+ (UIColor *)hz_getColor:(NSString *)hexColor;
+ (UIColor *)hz_getColor:(NSString *)hexColor alpha:(NSString *)alpha;
@end

NS_ASSUME_NONNULL_END
