//
//  UIImage+AssetsPickerParam.m
//  HZAssetsPicker
//
//  Created by THS on 2024/2/22.
//

#import "UIImage+AssetsPickerParam.h"
#import <objc/runtime.h>

@implementation UIImage (AssetsPickerParam)
#pragma mark - Associated
- (NSString *)title {
    return objc_getAssociatedObject(self, @selector(title));
}
- (void)setTitle:(NSString *)title {
    objc_setAssociatedObject(self, @selector(title), title, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long long)createTime {
    return [objc_getAssociatedObject(self, @selector(createTime)) longLongValue];
}
- (void)setCreateTime:(long long)createTime {
    objc_setAssociatedObject(self, @selector(createTime), @(createTime), OBJC_ASSOCIATION_ASSIGN);
}

@end
