//
//  HZVerticalButton.h
//  HZUIKit
//
//  Created by THS on 2024/2/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HZVerticalButton : UIButton

+ (HZVerticalButton *)buttonWithSize:(CGSize)size
                           imageSize:(CGSize)imageSize
                               image:(UIImage *)image
                     verticalSpacing:(CGFloat)verticalSpacing
                               title:(NSString *)title
                          titleColor:(UIColor *)titleColor
                                font:(UIFont *)font;
- (void)enableMultiLineTitle:(BOOL)enable;

- (void)setSelectImage:(UIImage *)selectImage selectTitleColor:(UIColor *)selectTitleColor;
- (void)verticalButtonSelected:(BOOL)selected;

@end

NS_ASSUME_NONNULL_END
