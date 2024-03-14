//
//  HZAssetsPickerNavigationBar.h
//  HZAssetsPicker
//
//  Created by THS on 2024/2/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HZAssetsPickerNavigationBar : UIView

@property (nonatomic, copy) void(^clickBackBlock)(void);
@property (nonatomic, copy) void(^clickRightBlock)(void);

- (void)configBackImage:(UIImage *)image;
- (void)configRightTitle:(NSString *)title;
- (void)configTitle:(NSString *)title;

- (void)configSwipeUpMode:(BOOL)isSwipeUpMode;

- (void)updateNextButtonEnable:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
