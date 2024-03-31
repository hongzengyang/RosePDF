//
//  HZBaseNavigationBar.h
//  RosePDF
//
//  Created by THS on 2024/2/6.
//

#import <UIKit/UIKit.h>


@interface HZBaseNavigationBar : UIView

@property (nonatomic, copy) void(^clickBackBlock)(void);
@property (nonatomic, copy) void(^clickRightBlock)(void);

- (void)configBackImage:(UIImage *)image;
- (void)configRightTitle:(NSString *)title;
- (void)configTitle:(NSString *)title;

- (void)setBackHidden:(BOOL)hidden;
- (void)setRightHidden:(BOOL)hidden;

@end

