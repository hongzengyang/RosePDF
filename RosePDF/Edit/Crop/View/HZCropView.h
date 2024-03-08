//
//  HZCropView.h
//  RosePDF
//
//  Created by THS on 2024/3/6.
//

#import <UIKit/UIKit.h>
#import "HZGeometry.h"

@protocol HZCropViewDelegate <NSObject>

@optional
- (void)viewingAtPoint:(CGPoint)viewPoint;
- (void)stopViewing;
- (void)touchsBegan;
- (void)touchsCancelled;
@end

@interface HZCropView : UIView

@property (nonatomic, weak) id <HZCropViewDelegate>delegate;

- (id)initWithFrame:(CGRect)frame insets:(UIEdgeInsets)insets;

- (NSArray *)cornerPoints;

- (void)setCornerPoints:(NSArray *)points;

- (void)hideCornerPoints;
- (void)showCornerPoints;

- (void)resetFrame;

- (void)changePointsScale:(CGFloat)scale;

+ (BOOL)isCornerPointsValidate:(NSArray *)points;

@end
