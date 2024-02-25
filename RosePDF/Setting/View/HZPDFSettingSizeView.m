//
//  HZPDFSettingSizeView.m
//  RosePDF
//
//  Created by THS on 2024/2/20.
//

#import "HZPDFSettingSizeView.h"
#import "HZCommonHeader.h"
#import "HZPDFSizeViewController.h"

@interface HZPDFSettingSizeView()
@property (nonatomic, strong) HZProjectModel *project;

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *sizeLab;

@end
@implementation HZPDFSettingSizeView

- (instancetype)initWithFrame:(CGRect)frame project:(HZProjectModel *)project {
    if (self = [super initWithFrame:frame]) {
        self.project = project;
        [self configView];
    }
    return self;
}

- (void)configView {
    UILabel *titleLab = [[UILabel alloc] init];
    [self addSubview:titleLab];
    titleLab.font = [UIFont systemFontOfSize:17];
    titleLab.textColor = [UIColor blackColor];
    titleLab.text = NSLocalizedString(@"str_pagesize", nil);
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(16);
        make.top.equalTo(self);
        make.height.mas_equalTo(70);
        make.width.mas_equalTo(250);
    }];
    self.titleLab = titleLab;
    
    UIImageView *iconImageView = [[UIImageView alloc] init];
    [self addSubview:iconImageView];
    iconImageView.contentMode = UIViewContentModeCenter;
    iconImageView.image = [UIImage imageNamed:@"rose_arrow"];
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self).offset(-14);
        make.width.height.mas_equalTo(28);
    }];
    
    UILabel *sizeLab = [[UILabel alloc] init];
    [self addSubview:sizeLab];
    sizeLab.font = [UIFont systemFontOfSize:14];
    sizeLab.textColor = hz_getColor(@"888888");
    sizeLab.text = [[self class] sizeTitleWithPdfSize:self.project.pdfSize];
    [sizeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(iconImageView.mas_leading);
    }];
    self.sizeLab = sizeLab;
    
    UIButton *sizeBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self addSubview:sizeBtn];
    [sizeBtn addTarget:self action:@selector(clickSizeButton) forControlEvents:(UIControlEventTouchUpInside)];
    sizeBtn.backgroundColor = [UIColor clearColor];
    [sizeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.trailing.equalTo(iconImageView);
        make.leading.equalTo(sizeLab);
    }];
}

- (void)clickSizeButton {
    HZPDFSizeViewController *vc = [[HZPDFSizeViewController alloc] initWithInputPDFSize:self.project.pdfSize];
    @weakify(self);
    vc.SelectPdfSizeBlock = ^(HZPDFSize size) {
        @strongify(self);
        self.project.pdfSize = size;
        self.sizeLab.text = [[self class] sizeTitleWithPdfSize:size];
    };
    
    UIViewController *contorller = [UIView hz_viewController];
    [contorller presentViewController:vc animated:YES completion:^{
        
    }];
}

+ (NSString *)sizeTitleWithPdfSize:(HZPDFSize)size {
    NSString *text = @"";
    switch (size) {
        case HZPDFSize_autoFit:
            text = @"Auto Fit";
            break;
        case HZPDFSize_A3:
            text = @"A3";
            break;
        case HZPDFSize_A4:
            text = @"A4";
            break;
        case HZPDFSize_A5:
            text = @"A5";
            break;
        case HZPDFSize_B4:
            text = @"B4";
            break;
        case HZPDFSize_B5:
            text = @"B5";
            break;
        case HZPDFSize_Executive:
            text = @"Executive";
            break;
        case HZPDFSize_Legal:
            text = @"Legal";
            break;
        case HZPDFSize_Letter:
            text = @"Letter";
            break;
        default:
            break;
    }
    return text;
}
+ (NSString *)sizeDescWithPdfSize:(HZPDFSize)size {
    NSString *text = @"";
    switch (size) {
        case HZPDFSize_autoFit:
            text = NSLocalizedString(@"str_size_autofit_desc", nil);
            break;
        case HZPDFSize_A3:
            text = @"297*420mm";
            break;
        case HZPDFSize_A4:
            text = @"210*297mm";
            break;
        case HZPDFSize_A5:
            text = @"148*210mm";
            break;
        case HZPDFSize_B4:
            text = @"250*353mm";
            break;
        case HZPDFSize_B5:
            text = @"176*250mm";
            break;
        case HZPDFSize_Executive:
            text = @"184*267mm";
            break;
        case HZPDFSize_Legal:
            text = @"216*356mm";
            break;
        case HZPDFSize_Letter:
            text = @"216*279mm";
            break;
        default:
            break;
    }
    return text;
}

@end


