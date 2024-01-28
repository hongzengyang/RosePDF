//
//  UIView+HZCategory.m
//  HZUIKit
//
//  Created by THS on 2024/1/25.
//

#import "UIView+HZCategory.h"
#import <objc/runtime.h>

static const NSString *clickSetActionKey = @"clickSetActionKey";
static const NSString *tapGestureKey = @"tapGestureKey";

#define gradient_layer_name  @"gradient_layer_name"
#define separater_layer_name @"separater_layer_name"


@implementation UIView (HZCategory)

// Retrieve and set the origin
- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)aPoint {
    CGRect newframe = self.frame;
    newframe.origin = aPoint;
    self.frame = newframe;
}


// Retrieve and set the size
- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)aSize {
    CGRect newframe = self.frame;
    newframe.size = aSize;
    self.frame = newframe;
}

// Query other frame locations
- (CGPoint)bottomRight {
    CGFloat x = self.frame.origin.x + self.frame.size.width;
    CGFloat y = self.frame.origin.y + self.frame.size.height;
    return CGPointMake(x, y);
}

- (CGPoint)bottomLeft {
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y + self.frame.size.height;
    return CGPointMake(x, y);
}

- (CGPoint)topRight {
    CGFloat x = self.frame.origin.x + self.frame.size.width;
    CGFloat y = self.frame.origin.y;
    return CGPointMake(x, y);
}


// Retrieve and set height, width, top, bottom, left, right
- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)newheight {
    CGRect newframe = self.frame;
    newframe.size.height = newheight;
    self.frame = newframe;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)newwidth {
    CGRect newframe = self.frame;
    newframe.size.width = newwidth;
    self.frame = newframe;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)newtop {
    CGRect newframe = self.frame;
    newframe.origin.y = newtop;
    self.frame = newframe;
}


- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)newleft {
    CGRect newframe = self.frame;
    newframe.origin.x = newleft;
    self.frame = newframe;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)newbottom {
    CGRect newframe = self.frame;
    newframe.origin.y = newbottom - self.frame.size.height;
    self.frame = newframe;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)newright {
    CGFloat delta = newright - (self.frame.origin.x + self.frame.size.width);
    CGRect newframe = self.frame;
    newframe.origin.x += delta ;
    self.frame = newframe;
}

+ (CGFloat)hz_safeTop {
    if (@available(iOS 11.0, *)) {
        return [UIApplication sharedApplication].delegate.window.safeAreaInsets.top;
    }

    return 0;
}
+ (CGFloat)hz_safeBottom {
    if (@available(iOS 11.0, *)) {
        return [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    }

    return 0;
}

+ (UIViewController *)hz_viewController {
    UIViewController *resultVC;
    resultVC = [self topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController *)topViewController:(UIViewController *)vc {
    if ([vc presentedViewController]) {
        return [self topViewController:vc.presentedViewController];
    }else if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self topViewController:[(UINavigationController *)vc topViewController]];
    }else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self topViewController:[(UITabBarController *)vc selectedViewController]];
    }else {
        return vc;
    }
    return nil;
}

#pragma mark - click Action
- (void)hz_clickBlock:(ViewClickBlock)block {
    if(block != nil) {
        objc_setAssociatedObject(self, &clickSetActionKey, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *oldGesture = [self tapGesture];
        if( oldGesture != nil) {
            [self removeGestureRecognizer:oldGesture];
        }
        UITapGestureRecognizer *newGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blockHandleAction:)];
        [self setTapGesture:newGesture];
        [self addGestureRecognizer:newGesture];
    }else {
        objc_setAssociatedObject(self, &clickSetActionKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        UITapGestureRecognizer*oldGesture = [self tapGesture];
        if(oldGesture != nil) {
            [self removeGestureRecognizer:oldGesture];
        }
    }
}

- (void)setTapGesture:(UITapGestureRecognizer *)tap {
    if(tap !=nil){
        objc_setAssociatedObject(self, &tapGestureKey, tap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }else {
        objc_setAssociatedObject(self, &tapGestureKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (UITapGestureRecognizer *)tapGesture {
    return objc_getAssociatedObject(self, &tapGestureKey);
}

- (void)blockHandleAction:(UIGestureRecognizer *)sender {
    ViewClickBlock block =objc_getAssociatedObject(self, &clickSetActionKey);
    if(block != nil) {
        block();
    }
}

#pragma mark - 圆角
- (void)hz_addCorner:(UIRectCorner)rectCorner radious:(CGFloat)radious {
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(radious, radious)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = bezierPath.CGPath;
    self.layer.mask = maskLayer;
}

#pragma mark - 渐变
- (void)hz_addGradientWithColors:(NSArray<UIColor *> *)colors startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    [self.layer.sublayers enumerateObjectsUsingBlock:^(__kindof CALayer *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.name isEqualToString:gradient_layer_name]) {
            [obj removeFromSuperlayer];
        }
    }];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.name = gradient_layer_name;
    gradientLayer.frame = self.bounds;
    gradientLayer.colors = [self gradientColorsWithColors:colors];
    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint = endPoint;
    [self.layer insertSublayer:gradientLayer atIndex:0];
}

- (NSArray *)gradientColorsWithColors:(NSArray<UIColor *> *)colors {
    NSMutableArray *gradientColors = [NSMutableArray array];
    for (UIColor *color in colors) {
        [gradientColors addObject:(id)color.CGColor];
    }
    return gradientColors;
}

#pragma mark - 分割
- (void)hz_addSeparateLineWithLineHeight:(CGFloat)lineHeight addAtTop:(BOOL)addAtTop {
    [self.layer.sublayers enumerateObjectsUsingBlock:^(__kindof CALayer *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.name isEqualToString:separater_layer_name]) {
            [obj removeFromSuperlayer];
        }
    }];
    
    CALayer *sepLayer = [[CALayer alloc] init];
    sepLayer.name = separater_layer_name;
    if (addAtTop) {
        sepLayer.frame = CGRectMake(0, 0, self.width, lineHeight);
    }else {
        sepLayer.frame = CGRectMake(0, self.height - lineHeight, self.width, lineHeight);
    }
    sepLayer.backgroundColor = [UIColor colorWithRed:229/255.0 green:230/255.0 blue:235/255.0 alpha:1.0].CGColor;
    [self.layer addSublayer:sepLayer];
}

@end

