//
//  HZCameraButton.m
//  HZAssetsPicker
//
//  Created by THS on 2024/3/5.
//

#import "HZCameraButton.h"
#import <HZUIKit/HZUIKit.h>
#define DegreesToRadians(x) (M_PI*(x)/180.0) //把角度转换成PI的方式
#define cap_line_width   3.0

@interface HZCameraButton ()

@property (nonatomic, strong) CAShapeLayer *actionLayer;
@property (nonatomic, strong) CAShapeLayer *innerLayer;
@property (nonatomic, strong) CAGradientLayer *outterLayer;

@property (nonatomic, strong) CALayer *imageLayer;
@end


@implementation HZCameraButton

- (instancetype)initCustomWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

-(void)initView {
    //内圆
    self.innerLayer = [self createInnerLayer];
    self.imageLayer = [self createImageLayer];
    [_innerLayer addSublayer:_imageLayer];
    [self.layer addSublayer:_innerLayer];
    
    //外面的环形
    self.outterLayer = [self createOutterLayerWithStartAngle:DegreesToRadians(0) endAngle:DegreesToRadians(360) color:[UIColor hz_getColor:@"2B96FA"] opacity:1.0];
    [self.layer insertSublayer:_outterLayer below:_innerLayer];
    
    //画圈
    self.actionLayer.hidden = NO;
    [self.layer insertSublayer:self.actionLayer above:_outterLayer];
}

- (void)startAnimation {
    [self stopAnimation];
    
    CABasicAnimation *baseAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    [baseAnimation setFromValue:@0.0];
    [baseAnimation setToValue:@1.0];
    [baseAnimation setDuration:1.0];
    baseAnimation.removedOnCompletion = YES;
    
    [_actionLayer addAnimation:baseAnimation forKey:@"strokeEnd"];
    
    self.outterLayer.hidden = YES;
}

- (void)stopAnimation {
    [_actionLayer removeAllAnimations];
    self.outterLayer.hidden = NO;
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
}

#pragma mark - set & get
-(CAShapeLayer *)createInnerLayer {
    CGRect innerFrame = [self innerViewFrame];
    UIBezierPath *innerpath = [UIBezierPath bezierPathWithRoundedRect:innerFrame cornerRadius:[self innerCircleRadius]];
    [innerpath stroke];
    //路径填充，必须是一个完整的封闭路径
    [innerpath fill];
    
    CAShapeLayer *innerLayer = [[CAShapeLayer alloc] init];
    innerLayer.path = [innerpath CGPath];
//    innerLayer.fillColor =  _isPad?[[UIColor whiteColor] CGColor]:[sh_mainColor CGColor];
    innerLayer.fillColor = [[UIColor hz_getColor:@"2B96FA"] CGColor];
    innerLayer.opacity = 1.0;
    innerLayer.shadowColor = [UIColor grayColor].CGColor;
    innerLayer.shadowOffset = CGSizeMake(0, 0); // 阴影的偏移量
    innerLayer.shadowRadius = 1.0; // 阴影扩散的范围控制
    innerLayer.shadowOpacity = 0.5; // 阴影透明度
    return innerLayer;
}

- (CALayer *)createImageLayer {
    return nil;
}

//-(CAShapeLayer *)createOutterLayerWithStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle color:(UIColor *)color opacity:(CGFloat)opacity
//{
//    CGFloat radius = [self outterCircleRadius];
//    UIBezierPath *outterPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0)
//                                                              radius:radius
//                                                          startAngle:startAngle
//                                                            endAngle:endAngle
//                                                           clockwise:YES];
//    CGFloat lineWidth = 3.0;
//    CAShapeLayer *layer = [CAShapeLayer layer];
//    layer.frame = self.bounds;
//    layer.path = [outterPath CGPath];
//    layer.fillColor = [UIColor clearColor].CGColor;
//    layer.strokeColor =  [color CGColor];
//    layer.opacity = opacity;
//    layer.lineWidth = lineWidth;
//    return layer;
//}

-(CAGradientLayer *)createOutterLayerWithStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle color:(UIColor *)color opacity:(CGFloat)opacity {
    // 设置渐变层的颜色变化范围
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = self.bounds ;
    
    // 颜色分配
    layer.colors = @[(__bridge id)[UIColor hz_getColor:@"2B96FA"].CGColor,
                     (__bridge id)[UIColor hz_getColor:@"83BAF2"].CGColor];
    
    
    // 起始点
    layer.startPoint = CGPointMake(0, 0);
    
    // 结束点
    layer.endPoint   = CGPointMake(1, 0);
    
    CGFloat radius = [self outterCircleRadius];
    CGPoint center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.width * 0.5) ;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                        radius:radius
                                                    startAngle:DegreesToRadians(0)
                                                      endAngle:DegreesToRadians(360)
                                                     clockwise:YES] ;
    
    // 创建蒙板层
    CAShapeLayer *maskLayer = [CAShapeLayer layer] ;
    maskLayer.backgroundColor = [UIColor yellowColor].CGColor;
    maskLayer.lineWidth = cap_line_width;
    maskLayer.lineCap = kCALineCapRound ; // 显得起始点形状<此刻是圆形的>
    maskLayer.strokeStart = 0.0 ;
    maskLayer.strokeEnd = 1.0 ;
    maskLayer.path = [path CGPath];
    maskLayer.fillColor = [UIColor clearColor].CGColor ;
    maskLayer.strokeColor = [UIColor whiteColor].CGColor ;
    [layer setMask:maskLayer];
    
    return layer;
}

- (CGFloat)innerCircleRadius {
    return self.frame.size.width / 2.0 - 6;
}

- (CGFloat)outterCircleRadius {
    return self.frame.size.width / 2.0 - cap_line_width;
}

-(CGRect)innerViewFrame {
    CGFloat radius = [self innerCircleRadius];
    return CGRectMake(self.frame.size.width/2.0-radius, self.frame.size.height/2.0-radius, radius*2, radius*2);
}

-(CGRect)outterViewFrame {
    CGFloat radius = [self outterCircleRadius];
    return CGRectMake(self.frame.size.width/2.0-radius, self.frame.size.height/2.0-radius, radius*2, radius*2);
}

-(CAShapeLayer *)actionLayer {
    if (!_actionLayer)
    {
        _actionLayer = [CAShapeLayer layer];
        _actionLayer.strokeColor = [UIColor whiteColor].CGColor;
        _actionLayer.opacity = 1.0;
        _actionLayer.fillColor = [UIColor clearColor].CGColor;
        _actionLayer.lineWidth = cap_line_width;
        _actionLayer.lineCap = @"round";
        _actionLayer.lineJoin = @"round";
        _actionLayer.strokeStart = 0.0;
        _actionLayer.strokeEnd = 0.0;
        
        CGFloat radius = [self outterCircleRadius];
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0) radius:radius startAngle:-DegreesToRadians(90) endAngle:(DegreesToRadians(360)-DegreesToRadians(90)) clockwise:YES];
        _actionLayer.path = bezierPath.CGPath;
    }
    
    return _actionLayer;
}

@end
