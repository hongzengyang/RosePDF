//
//  HZDetailBottomView.m
//  RosePDF
//
//  Created by THS on 2024/2/26.
//

#import "HZDetailBottomView.h"
#import "HZCommonHeader.h"

@interface HZDetailBottomView()

@property (nonatomic, strong) HZProjectModel *project;

@property (nonatomic, strong) HZVerticalButton *deleteBtn;

@end

@implementation HZDetailBottomView
- (instancetype)initWithProject:(HZProjectModel *)project {
    if (self = [super init]) {
        self.project = project;
        [self configView];
    }
    return self;
}
- (void)configView {
    self.backgroundColor = [UIColor whiteColor];
    
    NSArray *images = @[[UIImage imageNamed:@"rose_detail_rename"],[UIImage imageNamed:@"rose_detail_edit"],[UIImage imageNamed:@"rose_detail_setting"],[UIImage imageNamed:@"rose_detail_share"],[UIImage imageNamed:@"rose_edit_delete"]];
    NSArray *titles = @[NSLocalizedString(@"str_rename", nil),NSLocalizedString(@"str_edit", nil),NSLocalizedString(@"str_settings", nil),NSLocalizedString(@"str_share", nil),NSLocalizedString(@"str_delete", nil)];
    CGFloat btnWidth = 50;
    CGFloat btnHeight = 37;
    CGFloat startLeading = 19;
    CGFloat space = (ScreenWidth - (startLeading * 2) - (btnWidth * 5)) / 4.0;
    for (int i = 0; i < images.count; i++) {
        HZVerticalButton *btn = [HZVerticalButton buttonWithSize:CGSizeMake(btnWidth, btnHeight) imageSize:CGSizeMake(22, 22) image:images[i] verticalSpacing:3 title:titles[i] titleColor:i == 4 ? hz_getColor(@"FF3B30") : hz_getColor(@"333333") font:[UIFont systemFontOfSize:10 weight:(UIFontWeightMedium)]];
        [btn enableMultiLineTitle:NO];
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(detailBottomViewClickItem:)]) {
        [self.delegate detailBottomViewClickItem:item.tag];
    }
}

@end
