//
//  HZHomeTableHeaderView.m
//  RosePDF
//
//  Created by THS on 2024/2/5.
//

#import "HZHomeTableHeaderView.h"
#import "HZCommonHeader.h"
#import "HZSearchViewController.h"

@interface HZHomeTableHeaderView()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIView *searchView;

@end

@implementation HZHomeTableHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configView];
    }
    return self;
}

- (void)configView {
    [self addSubview:self.titleLab];
    [self addSubview:self.searchView];
}

- (void)clickSearch {
    HZSearchViewController *vc = [[HZSearchViewController alloc] init];
    [[UIView hz_viewController].navigationController pushViewController:vc animated:NO];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(hz_safeTop + 53);
        make.leading.equalTo(self).offset(0);
    }];
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(0);
        make.trailing.equalTo(self).offset(0);
        make.top.equalTo(self.titleLab.mas_bottom).offset(18);
        make.height.mas_equalTo(36);
    }];
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:30 weight:(UIFontWeightBold)];
        _titleLab.textColor = hz_1_textColor;
        _titleLab.text = NSLocalizedString(@"str_files", nil);
    }
    return _titleLab;
}

- (UIView *)searchView {
    if (!_searchView) {
        UIView *view = [[UIView alloc] init];
        _searchView = view;
        _searchView.backgroundColor = hz_2_bgColor;
        _searchView.layer.cornerRadius = 10;
        _searchView.layer.masksToBounds = YES;
        
        UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rose_search_icon"]];
        [_searchView addSubview:iconImageView];
        [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_searchView);
            make.leading.equalTo(_searchView).offset(4);
            make.width.height.mas_equalTo(28);
        }];
        
        UITextField *textField = [[UITextField alloc] init];
        textField.placeholder = NSLocalizedString(@"str_search", nil);
        // 设置 placeholder 的颜色和字体
        NSDictionary *attributes = @{
            NSForegroundColorAttributeName: hz_getColor(@"888888"), // 设置颜色
            NSFontAttributeName: [UIFont systemFontOfSize:16] // 设置字体
        };
        NSAttributedString *attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:attributes];
        textField.attributedPlaceholder = attributedPlaceholder;
        [_searchView addSubview:textField];
        [textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.top.bottom.equalTo(_searchView);
            make.leading.equalTo(_searchView).offset(36);
            make.trailing.equalTo(_searchView).offset(-36);
        }];
        textField.userInteractionEnabled = NO;
        
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_searchView addSubview:button];
        [button addTarget:self action:@selector(clickSearch) forControlEvents:(UIControlEventTouchUpInside)];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(view);
        }];
    }
    return _searchView;
}

@end
