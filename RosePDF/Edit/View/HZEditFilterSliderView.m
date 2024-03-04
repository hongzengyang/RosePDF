//
//  HZEditFilterSliderView.m
//  RosePDF
//
//  Created by THS on 2024/3/2.
//

#import "HZEditFilterSliderView.h"
#import "HZCommonHeader.h"

@interface HZEditFilterSliderView()

@property (nonatomic, assign) CGFloat min;
@property (nonatomic, assign) CGFloat max;
@property (nonatomic, assign, readwrite) CGFloat value;
@property (nonatomic, assign) CGFloat defaultValue;

@property (nonatomic, strong) UIView *userTouchView;
@property (nonatomic, strong) UIView *trackView;
@property (nonatomic, strong) UIView *thumbView;
@property (nonatomic, strong) UIView *impactView;

@property (nonatomic, strong) UIView *gradientView;

@end

@implementation HZEditFilterSliderView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configView];
    }
    return self;
}

- (void)configView {
    self.userTouchView = [[UIView alloc] initWithFrame:CGRectMake(6, 0, self.width - 12, self.height)];
    [self addSubview:self.userTouchView];
    
    self.trackView = [[UIView alloc] initWithFrame:CGRectMake(0, (self.userTouchView.height - 2)/2.0, self.userTouchView.width, 2)];
    self.trackView.backgroundColor = hz_getColor(@"8B8B8B");
    self.trackView.layer.cornerRadius = self.trackView.height/2.0;
    self.trackView.layer.masksToBounds = YES;
    [self.userTouchView addSubview:self.trackView];
    
    self.gradientView = [[UIView alloc] init];
    [self.userTouchView addSubview:self.gradientView];
    
    self.impactView = [[UIView alloc] initWithFrame:CGRectMake(0, (self.userTouchView.height - 4)/2.0, 2, 4)];
    self.impactView.backgroundColor = hz_getColor(@"A9BFCF");
    self.impactView.layer.cornerRadius = 2;
    self.impactView.layer.masksToBounds = YES;
    [self.userTouchView addSubview:self.impactView];

    self.thumbView = [[UIView alloc] initWithFrame:CGRectMake(0, (self.userTouchView.height - 12)/2.0, 12, 12)];
    self.thumbView.layer.cornerRadius = self.thumbView.height/2.0;
    self.thumbView.layer.masksToBounds = YES;
    [self.userTouchView addSubview:self.thumbView];
    [self.thumbView hz_addGradientWithColors:@[hz_main_color,hz_getColor(@"83BAF2")] startPoint:CGPointMake(0, 0.5) endPoint:CGPointMake(1, 0.5)];
}

- (void)updateWithMin:(CGFloat)min max:(CGFloat)max value:(CGFloat)value defaultValue:(CGFloat)defaultValue {
    NSLog(@"debug--min:%@,max:%@,value:%@,default:%@",@(min),@(max),@(value),@(defaultValue));
    self.min = min;
    self.max = max;
    self.value = value;
    self.defaultValue = defaultValue;
    
    CGFloat impactPercent = (self.defaultValue - self.min) / (self.max - self.min);
    self.impactView.centerX = self.impactView.superview.width * impactPercent;
    
    [self updateViewFrame];
}

- (void)updateViewFrame {
    CGFloat valuePercent = (self.value - self.min) / (self.max - self.min);
    self.thumbView.centerX = self.thumbView.superview.width * valuePercent;
    
    if (self.thumbView.centerX < self.impactView.centerX) {
        [self.gradientView setFrame:CGRectMake(self.thumbView.centerX, self.trackView.top, self.impactView.centerX - self.thumbView.centerX, self.trackView.height)];
    }else {
        [self.gradientView setFrame:CGRectMake(self.impactView.centerX, self.trackView.top, self.thumbView.centerX - self.impactView.centerX, self.trackView.height)];
    }
    [self.gradientView hz_addGradientWithColors:@[hz_main_color,hz_getColor(@"83BAF2")] startPoint:CGPointMake(0, 0.5) endPoint:CGPointMake(1, 0.5)];
    self.gradientView.layer.cornerRadius = self.gradientView.height/2.0;
    self.gradientView.layer.masksToBounds = YES;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint pt = [[touches anyObject] locationInView:self.userTouchView];
    
    CGFloat touchX = pt.x;
    if (touchX < 0) {
        touchX = 0;
    }
    if (touchX > self.userTouchView.width) {
        touchX = self.userTouchView.width;
    }
    
    self.value = (touchX / self.userTouchView.width) * (self.max - self.min) + self.min;
    [self updateViewFrame];
    
//    if (self.slideEndBlock) {
//        self.slideEndBlock();
//    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint pt = [[touches anyObject] locationInView:self.userTouchView];
    
    CGFloat touchX = pt.x;
    if (touchX < 0) {
        touchX = 0;
    }
    if (touchX > self.userTouchView.width) {
        touchX = self.userTouchView.width;
    }
    
    self.value = (touchX / self.userTouchView.width) * (self.max - self.min) + self.min;
    [self updateViewFrame];
    
    if (self.slideEndBlock) {
        self.slideEndBlock();
    }
}

@end
