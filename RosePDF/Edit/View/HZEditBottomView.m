//
//  HZEditBottomView.m
//  RosePDF
//
//  Created by THS on 2024/2/6.
//

#import "HZEditBottomView.h"
#import "HZCommonHeader.h"

@interface HZEditBottomView()

@property (nonatomic, strong) HZEditDataboard *databoard;

@end

@implementation HZEditBottomView
- (instancetype)initWithDataboard:(HZEditDataboard *)databoard {
    if (self = [super init]) {
        self.databoard = databoard;
        [self configView];
    }
    return self;
}
- (void)configView {
    self.backgroundColor = [UIColor whiteColor];
    
    NSArray *images = @[[UIImage imageNamed:@"rose_edit_filter"],[UIImage imageNamed:@"rose_edit_left"],[UIImage imageNamed:@"rose_edit_right"],[UIImage imageNamed:@"rose_edit_crop"],[UIImage imageNamed:@"rose_edit_order"],[UIImage imageNamed:@"rose_edit_delete"]];
    NSArray *titles = @[NSLocalizedString(@"str_filter", nil),NSLocalizedString(@"str_left", nil),NSLocalizedString(@"str_right", nil),NSLocalizedString(@"str_crop", nil),NSLocalizedString(@"str_reorder", nil),NSLocalizedString(@"str_delete", nil)];
    CGFloat btnWidth = 40;
    CGFloat btnHeight = 37;
    CGFloat startLeading = 19;
    CGFloat space = (ScreenWidth - (startLeading * 2) - (btnWidth * 6)) / 5.0;
    for (int i = 0; i < images.count; i++) {
        HZVerticalButton *btn = [HZVerticalButton buttonWithSize:CGSizeMake(btnWidth, btnHeight) imageSize:CGSizeMake(22, 22) image:images[i] verticalSpacing:3 title:titles[i] titleColor:i == 5 ? hz_getColor(@"FF3B30") : hz_getColor(@"333333") font:[UIFont systemFontOfSize:10]];
        [self addSubview:btn];
        btn.tag = i;
        [btn addTarget:self action:@selector(clickItem:) forControlEvents:(UIControlEventTouchUpInside)];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(startLeading + i * (btnWidth + space));
            make.top.equalTo(self).offset(6);
            make.width.mas_equalTo(btnWidth);
            make.height.mas_equalTo(btnHeight);
        }];
    }
    
    
}

- (void)clickItem:(UIButton *)item {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editBottomViewClickItem:)]) {
        [self.delegate editBottomViewClickItem:item.tag];
    }
}

@end
