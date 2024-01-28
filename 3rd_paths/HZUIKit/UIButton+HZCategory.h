//
//  UIButton+HZCategory.h
//  HZUIKit
//
//  Created by THS on 2024/1/25.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SHButtonLayoutStyle) {
    SHButtonLayoutStyle_top,       // image在上，label在下
    SHButtonLayoutStyle_left,      // image在左，label在右
    SHButtonLayoutStyle_bottom,    // image在下，label在上
    SHButtonLayoutStyle_right      // image在右，label在左
};

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (HZCategory)

- (void)hz_setEnlargeEdge:(CGFloat)size;
- (void)hz_setEnlargeEdgeWithTop:(CGFloat) top right:(CGFloat) right bottom:(CGFloat) bottom left:(CGFloat) left;

/**
 *  设置button的titleLabel和imageView的布局样式，及间距
 *
 *  @param style titleLabel和imageView的布局样式
 *  @param space titleLabel和imageView的间距
 */
- (void)hz_layoutButtonWithStyle:(SHButtonLayoutStyle)style imageTitleSpace:(CGFloat)space;

@end

NS_ASSUME_NONNULL_END

