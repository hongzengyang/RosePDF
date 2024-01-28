//
//  UIView+HZCategory.h
//  HZUIKit
//
//  Created by THS on 2024/1/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ViewClickBlock)(void);

@interface UIView (HZCategory)



#pragma mark - 坐标
@property CGPoint origin;
@property CGSize size;

@property (readonly) CGPoint bottomLeft;
@property (readonly) CGPoint bottomRight;
@property (readonly) CGPoint topRight;

@property CGFloat height;
@property CGFloat width;

@property CGFloat top;
@property CGFloat left;

@property CGFloat bottom;
@property CGFloat right;

@property (nonatomic, assign) CGFloat centerX;

@property (nonatomic, assign) CGFloat centerY;

+ (CGFloat)hz_safeTop;
+ (CGFloat)hz_safeBottom;

+ (UIViewController *)hz_viewController;

- (void)hz_clickBlock:(ViewClickBlock)block;

- (void)hz_addCorner:(UIRectCorner)rectCorner radious:(CGFloat)radious;

//[0,0] is the top-left * corner of the layer, [1,1] is the bottom-right corner.
- (void)hz_addGradientWithColors:(NSArray<UIColor *> *)colors startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

- (void)hz_addSeparateLineWithLineHeight:(CGFloat)lineHeight addAtTop:(BOOL)addAtTop;

@end

NS_ASSUME_NONNULL_END
