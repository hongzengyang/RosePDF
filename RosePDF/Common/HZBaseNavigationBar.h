//
//  HZBaseNavigationBar.h
//  RosePDF
//
//  Created by THS on 2024/2/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HZBaseNavigationBar : UIView

@property (nonatomic, copy) void(^clickBackBlock)(void);
@property (nonatomic, copy) void(^clickRightBlock)(void);

- (void)configBackImage:(UIImage *)image;
- (void)configRightTitle:(NSString *)title;
- (void)configTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
