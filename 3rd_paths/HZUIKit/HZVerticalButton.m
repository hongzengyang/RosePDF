//
//  HZVerticalButton.m
//  HZUIKit
//
//  Created by THS on 2024/2/6.
//

#import "HZVerticalButton.h"
#import "UIView+HZCategory.h"


@interface HZVerticalButton ()

@property (nonatomic, strong) UIImageView *inner_imageView;
@property (nonatomic, strong) UILabel *inner_titleLab;

@property (nonatomic, strong) UIColor *nor_titleColor;
@property (nonatomic, strong) UIColor *sel_titleColor;

@property (nonatomic, strong) UIImage *nor_image;
@property (nonatomic, strong) UIImage *sel_image;

@end

@implementation HZVerticalButton

+ (HZVerticalButton *)buttonWithSize:(CGSize)size
                           imageSize:(CGSize)imageSize
                               image:(UIImage *)image
                     verticalSpacing:(CGFloat)verticalSpacing
                               title:(NSString *)title
                          titleColor:(UIColor *)titleColor
                                font:(UIFont *)font
                           multiLine:(BOOL)multiLine {
    HZVerticalButton *button = [HZVerticalButton buttonWithType:(UIButtonTypeCustom)];
    [button setSize:size];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((size.width - imageSize.width)/2.0, 0, imageSize.width, imageSize.height)];
    imageView.image = image;
    [button addSubview:imageView];
    button.inner_imageView = imageView;
    button.nor_image = image;
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, 0)];
    titleLab.font = font;
    titleLab.textColor = titleColor;
    titleLab.text = title;
    titleLab.textAlignment = NSTextAlignmentCenter;
    if (multiLine) {
        titleLab.numberOfLines = 2;
    }else {
        titleLab.numberOfLines = 1;
    }
    [titleLab sizeToFit];
    [titleLab setFrame:CGRectMake(0, imageView.bottom + verticalSpacing, size.width, titleLab.height)];
    [button addSubview:titleLab];
    button.inner_titleLab = titleLab;
    button.nor_titleColor = titleColor;
    
    return button;
}

- (void)enableMultiLineTitle:(BOOL)enable {
    if (enable) {
        self.inner_titleLab.numberOfLines = 2;
    }else {
        self.inner_titleLab.numberOfLines = 1;
    }
}

- (void)setSelectImage:(UIImage *)selectImage selectTitleColor:(UIColor *)selectTitleColor {
    self.sel_image = selectImage;
    self.sel_titleColor = selectTitleColor;
}

- (void)verticalButtonSelected:(BOOL)selected {
    if (selected) {
        self.inner_imageView.image = self.sel_image;
        self.inner_titleLab.textColor = self.sel_titleColor;
    }else {
        self.inner_imageView.image = self.nor_image;
        self.inner_titleLab.textColor = self.nor_titleColor;
    }
    
    self.selected = selected;
}

@end

