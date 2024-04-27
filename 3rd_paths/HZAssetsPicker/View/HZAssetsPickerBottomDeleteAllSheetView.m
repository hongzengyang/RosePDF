//
//  HZAssetsPickerBottomDeleteAllSheetView.m
//  HZAssetsPicker
//
//  Created by THS on 2024/4/24.
//

#import "HZAssetsPickerBottomDeleteAllSheetView.h"
#import <HZUIKit/HZUIKit.h>
#import <Masonry/Masonry.h>

@interface HZAssetsPickerBottomDeleteAllSheetView()
@property (nonatomic, copy) void(^clickBlock)(void);

@end

@implementation HZAssetsPickerBottomDeleteAllSheetView
- (instancetype)initWithRelatedView:(UIView *)relatedView clickBlock:(void (^)(void))clickBlock {
    if (self = [super init]) {
        self.clickBlock = clickBlock;
        [self configView:relatedView];
    }
    return self;
}

- (void)configView:(UIView *)relatedView {
    UIButton *fullBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self addSubview:fullBtn];
    [fullBtn addTarget:self action:@selector(clickCancelButton) forControlEvents:(UIControlEventTouchUpInside)];
    [fullBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    UIButton *removeBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self addSubview:removeBtn];
    [removeBtn setTitle:NSLocalizedString(@"str_remove_all", nil) forState:(UIControlStateNormal)];
    removeBtn.titleLabel.font = [UIFont systemFontOfSize:24 weight:(UIFontWeightRegular)];
    [removeBtn setTitleColor:[UIColor hz_getColor:@"FFFFFF"] forState:(UIControlStateNormal)];
    removeBtn.backgroundColor = [UIColor hz_getColor:@"FF3B30"];
    [removeBtn sizeToFit];
    [removeBtn setSize:CGSizeMake(removeBtn.width + removeBtn.height, removeBtn.height + 15)];
    removeBtn.layer.cornerRadius = 12;
    removeBtn.layer.masksToBounds = YES;
    
    CGRect relatedFrame = [relatedView.superview convertRect:relatedView.frame toView:[UIView hz_viewController].view];
    [removeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(15);
        make.top.mas_equalTo([UIScreen mainScreen].bounds.size.height - relatedView.height - 20 - removeBtn.height);
        make.width.mas_equalTo(removeBtn.width);
        make.height.mas_equalTo(removeBtn.height);
    }];
    
    [removeBtn addTarget:self action:@selector(clickRemoveAllButton) forControlEvents:(UIControlEventTouchUpInside)];
}

- (void)clickCancelButton {
    [self removeFromSuperview];
}

- (void)clickRemoveAllButton {
    if (self.clickBlock) {
        self.clickBlock();
    }
    [self removeFromSuperview];
}

@end
