//
//  HZEditFilterSliderView.h
//  RosePDF
//
//  Created by THS on 2024/3/2.
//

#import <UIKit/UIKit.h>


@interface HZEditFilterSliderView : UIView

@property (nonatomic, assign, readonly) CGFloat value;
@property (nonatomic, assign, readonly) CGFloat defaultValue;

@property (nonatomic, assign) BOOL debugMode;

@property (nonatomic, copy) void(^slideEndBlock)(void);



- (void)updateWithMin:(CGFloat)min max:(CGFloat)max value:(CGFloat)value defaultValue:(CGFloat)defaultValue;

@end

