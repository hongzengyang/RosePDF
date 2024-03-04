//
//  HZSlider.m
//  RosePDF
//
//  Created by THS on 2024/2/29.
//

#import "HZSlider.h"
#import "HZCommonHeader.h"

@implementation HZSlider

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        {
            {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 2)];
                view.layer.cornerRadius = view.height/2.0;
                view.layer.masksToBounds = YES;
                [view hz_addGradientWithColors:@[hz_main_color,hz_getColor(@"83BAF2")] startPoint:CGPointMake(0, 0.5) endPoint:CGPointMake(1, 0.5)];
                UIImage *image = [UIImage hz_createImageWithView:view];
                image = [image resizableImageWithCapInsets:(UIEdgeInsetsZero) resizingMode:(UIImageResizingModeStretch)];
                [self setMinimumTrackImage:image forState:UIControlStateNormal];
            }
            
            {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 2)];
                view.layer.cornerRadius = view.height/2.0;
                view.layer.masksToBounds = YES;
                view.backgroundColor = hz_getColor(@"8B8B8B");
                UIImage *image = [UIImage hz_createImageWithView:view];
                image = [image resizableImageWithCapInsets:(UIEdgeInsetsZero) resizingMode:(UIImageResizingModeStretch)];
                [self setMaximumTrackImage:image forState:UIControlStateNormal];
                
            }
        }
        
        {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.height, self.height)];
            [view hz_addGradientWithColors:@[hz_main_color,hz_getColor(@"83BAF2")] startPoint:CGPointMake(0, 0.5) endPoint:CGPointMake(1, 0.5)];
            view.layer.cornerRadius = view.height/2.0;
            view.layer.masksToBounds = YES;
            UIImage *image = [UIImage hz_createImageWithView:view];
            [self setThumbImage:image forState:(UIControlStateNormal)];
            [self setThumbImage:image forState:(UIControlStateSelected)];
        }
    }
    return self;
}
- (CGRect)trackRectForBounds:(CGRect)bounds {
    return CGRectMake(6, (self.frame.size.height - 2)/2.0, self.frame.size.width - 12, 2);
}
- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    return CGRectMake((self.frame.size.width - 12) * value, 0, 12, 12);
}

@end
