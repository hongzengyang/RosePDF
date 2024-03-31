//
//  HZPDFSizeViewController.m
//  RosePDF
//
//  Created by THS on 2024/2/20.
//

#import "HZPDFSizeViewController.h"
#import "HZCommonHeader.h"
#import "HZBaseNavigationBar.h"
#import "HZPDFSettingSizeView.h"

@interface HZPDFSizeViewController ()
@property (nonatomic, assign) HZPDFOrientation currentOrientation;
@property (nonatomic, assign) HZPDFSize currentPdfSize;

@property (nonatomic, strong) HZBaseNavigationBar *navBar;

@property (nonatomic, strong) UIImageView *selectOrientationImageView;
@property (nonatomic, strong) UIImageView *selectPdfSizeImageView;

@property (nonatomic, strong) NSMutableArray <UIButton *>*orientationButtons;
@property (nonatomic, strong) NSMutableArray <UIButton *>*pageSizeButtons;

@end

@implementation HZPDFSizeViewController

- (instancetype)initWithInputPDFSize:(HZPDFSize)pdfSize orientation:(HZPDFOrientation)orientation {
    if (self = [super init]) {
        self.currentOrientation = orientation;
        self.currentPdfSize = pdfSize;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.orientationButtons = [[NSMutableArray alloc] init];
    self.pageSizeButtons = [[NSMutableArray alloc] init];
    [self configView];
}

- (void)configView {
    [self.view addSubview:self.navBar];
    self.navBar.backgroundColor = [UIColor clearColor];
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(self.view);
        make.height.mas_equalTo(55);
    }];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.top.equalTo(self.navBar.mas_bottom);
    }];
    
    UILabel *orientationTitleLab = [[UILabel alloc] init];
    [scrollView addSubview:orientationTitleLab];
    orientationTitleLab.font = [UIFont systemFontOfSize:14];
    orientationTitleLab.textColor = hz_getColor(@"888888");
    orientationTitleLab.text = NSLocalizedString(@"str_orientation", nil);
    [orientationTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(32);
        make.top.equalTo(scrollView).offset(33);
    }];
    
    UIView *orientationContainerView = [[UIView alloc] init];
    orientationContainerView.backgroundColor = [UIColor whiteColor];
    orientationContainerView.layer.cornerRadius = 10;
    orientationContainerView.layer.masksToBounds = YES;
    [scrollView addSubview:orientationContainerView];
    
    UIView *portrait = [self createItemViewWithPdfOrientation:(HZPDFOrientation_portrait) addSeparater:YES width:self.view.width - 32];
    [orientationContainerView addSubview:portrait];
    [portrait mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(orientationContainerView);
        make.top.equalTo(orientationContainerView);
        make.height.mas_equalTo(56);
    }];
    UIView *landscape = [self createItemViewWithPdfOrientation:(HZPDFOrientation_landscape) addSeparater:NO width:self.view.width - 32];
    [orientationContainerView addSubview:landscape];
    [landscape mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(orientationContainerView);
        make.top.equalTo(portrait.mas_bottom);
        make.height.mas_equalTo(56);
    }];
    
    [orientationContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(16);
        make.trailing.equalTo(self.view).offset(-16);
        make.bottom.equalTo(landscape.mas_bottom);
        make.top.equalTo(orientationTitleLab.mas_bottom).offset(10);
    }];
    
    UILabel *pdfsizeTitleLab = [[UILabel alloc] init];
    [scrollView addSubview:pdfsizeTitleLab];
    pdfsizeTitleLab.font = [UIFont systemFontOfSize:14];
    pdfsizeTitleLab.textColor = hz_getColor(@"888888");
    pdfsizeTitleLab.text = NSLocalizedString(@"str_pagesize", nil);
    [pdfsizeTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(32);
        make.top.equalTo(orientationContainerView.mas_bottom).offset(33);
    }];
    
    UIView *pageSizeContainerView = [[UIView alloc] init];
    pageSizeContainerView.backgroundColor = [UIColor whiteColor];
    pageSizeContainerView.layer.cornerRadius = 10;
    pageSizeContainerView.layer.masksToBounds = YES;
    [scrollView addSubview:pageSizeContainerView];
    
    UIView *autoFit = [self createItemViewWithPdfSize:(HZPDFSize_autoFit) addSeparater:YES width:self.view.width - 32];
    [pageSizeContainerView addSubview:autoFit];
    [autoFit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(pageSizeContainerView);
        make.top.equalTo(pageSizeContainerView);
        make.height.mas_equalTo(56);
    }];
    UIView *A3 = [self createItemViewWithPdfSize:(HZPDFSize_A3) addSeparater:YES width:self.view.width - 32];
    [pageSizeContainerView addSubview:A3];
    [A3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(pageSizeContainerView);
        make.top.equalTo(autoFit.mas_bottom);
        make.height.mas_equalTo(56);
    }];
    UIView *A4 = [self createItemViewWithPdfSize:(HZPDFSize_A4) addSeparater:YES width:self.view.width - 32];
    [pageSizeContainerView addSubview:A4];
    [A4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(pageSizeContainerView);
        make.top.equalTo(A3.mas_bottom);
        make.height.mas_equalTo(56);
    }];
    UIView *A5 = [self createItemViewWithPdfSize:(HZPDFSize_A5) addSeparater:YES width:self.view.width - 32];
    [pageSizeContainerView addSubview:A5];
    [A5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(pageSizeContainerView);
        make.top.equalTo(A4.mas_bottom);
        make.height.mas_equalTo(56);
    }];
    UIView *B4 = [self createItemViewWithPdfSize:(HZPDFSize_B4) addSeparater:YES width:self.view.width - 32];
    [pageSizeContainerView addSubview:B4];
    [B4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(pageSizeContainerView);
        make.top.equalTo(A5.mas_bottom);
        make.height.mas_equalTo(56);
    }];
    UIView *B5 = [self createItemViewWithPdfSize:(HZPDFSize_B5) addSeparater:YES width:self.view.width - 32];
    [pageSizeContainerView addSubview:B5];
    [B5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(pageSizeContainerView);
        make.top.equalTo(B4.mas_bottom);
        make.height.mas_equalTo(56);
    }];
    UIView *Executive = [self createItemViewWithPdfSize:(HZPDFSize_Executive) addSeparater:YES width:self.view.width - 32];
    [pageSizeContainerView addSubview:Executive];
    [Executive mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(pageSizeContainerView);
        make.top.equalTo(B5.mas_bottom);
        make.height.mas_equalTo(56);
    }];
    UIView *Legal = [self createItemViewWithPdfSize:(HZPDFSize_Legal) addSeparater:YES width:self.view.width - 32];
    [pageSizeContainerView addSubview:Legal];
    [Legal mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(pageSizeContainerView);
        make.top.equalTo(Executive.mas_bottom);
        make.height.mas_equalTo(56);
    }];
    UIView *Letter = [self createItemViewWithPdfSize:(HZPDFSize_Letter) addSeparater:NO width:self.view.width - 32];
    [pageSizeContainerView addSubview:Letter];
    [Letter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(pageSizeContainerView);
        make.top.equalTo(Legal.mas_bottom);
        make.height.mas_equalTo(56);
    }];
    
    [pageSizeContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(16);
        make.trailing.equalTo(self.view).offset(-16);
        make.height.mas_equalTo(9 * 56);
        make.bottom.equalTo(scrollView.mas_bottom).offset(-50);
        make.top.equalTo(pdfsizeTitleLab.mas_bottom).offset(10);
    }];
    
    self.selectOrientationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rose_pdf_size_select"]];
    self.selectOrientationImageView.contentMode = UIViewContentModeCenter;
    [orientationContainerView addSubview:self.selectOrientationImageView];
    [self.selectOrientationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(orientationContainerView).offset(-14);
        make.width.height.mas_equalTo(22);
    }];
    
    self.selectPdfSizeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rose_pdf_size_select"]];
    self.selectPdfSizeImageView.contentMode = UIViewContentModeCenter;
    [pageSizeContainerView addSubview:self.selectPdfSizeImageView];
    [self.selectPdfSizeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(pageSizeContainerView).offset(-14);
        make.width.height.mas_equalTo(22);
    }];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    [self updatePdfSizeSelectImageView];
    [self updateOrientationSelectImageView];
}

- (void)updatePdfSizeSelectImageView {
    [self.pageSizeButtons enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == self.currentPdfSize) {
            [self.selectPdfSizeImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(obj);
                make.trailing.equalTo(obj).offset(-14);
                make.width.height.mas_equalTo(22);
            }];
        }
    }];
}

- (void)updateOrientationSelectImageView {
    [self.orientationButtons enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == self.currentOrientation) {
            [self.selectOrientationImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(obj.superview);
                make.trailing.equalTo(obj).offset(-14);
                make.width.height.mas_equalTo(22);
            }];
        }
    }];
}

- (UIView *)createItemViewWithPdfOrientation:(HZPDFOrientation)orientation addSeparater:(BOOL)addSeparater width:(CGFloat)width {
    UIView *view = [[UIView alloc] init];
    view.size = CGSizeMake(width, 56);
    
    UILabel *titleLab = [[UILabel alloc] init];
    [view addSubview:titleLab];
    titleLab.font = [UIFont systemFontOfSize:17];
    titleLab.textColor = hz_getColor(@"000000");
    titleLab.text = [HZPDFSettingSizeView orientationTitleWithOrientation:orientation];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(view).offset(16);
        make.centerY.equalTo(view);
    }];
    
    if (addSeparater) {
        UIView *separater = [[UIView alloc] init];
        [view addSubview:separater];
        separater.backgroundColor = hz_2_bgColor;
        [separater mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(titleLab);
            make.bottom.trailing.equalTo(view);
            make.height.mas_equalTo(1.0);
        }];
    }
    
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [button addTarget:self action:@selector(clickPdfOrientationButton:) forControlEvents:(UIControlEventTouchUpInside)];
    button.tag = orientation;
    [view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    [self.orientationButtons addObject:button];
    return view;
}

- (void)clickPdfOrientationButton:(UIButton *)button {
    self.currentOrientation = button.tag;
    
    if (self.SelectPdfSizeBlock) {
        self.SelectPdfSizeBlock(self.currentPdfSize,self.currentOrientation);
    }
    
    [self updateOrientationSelectImageView];
}


- (UIView *)createItemViewWithPdfSize:(HZPDFSize)pdfSize addSeparater:(BOOL)addSeparater width:(CGFloat)width {
    UIView *view = [[UIView alloc] init];
    view.size = CGSizeMake(width, 56);
    
    UILabel *titleLab = [[UILabel alloc] init];
    [view addSubview:titleLab];
    titleLab.font = [UIFont systemFontOfSize:17];
    titleLab.textColor = hz_getColor(@"000000");
    titleLab.text = [HZPDFSettingSizeView sizeTitleWithPdfSize:pdfSize];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(view).offset(16);
        make.top.equalTo(view).offset(10);
    }];
    
    UILabel *descLab = [[UILabel alloc] init];
    [view addSubview:descLab];
    descLab.font = [UIFont systemFontOfSize:12];
    descLab.textColor = hz_getColorWithAlpha(@"484850", 0.5);
    descLab.text = [HZPDFSettingSizeView sizeDescWithPdfSize:pdfSize];
    [descLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(view).offset(16);
        make.top.equalTo(titleLab.mas_bottom).offset(7);
    }];
    
    if (addSeparater) {
        UIView *separater = [[UIView alloc] init];
        [view addSubview:separater];
        separater.backgroundColor = hz_2_bgColor;
        [separater mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(titleLab);
            make.bottom.trailing.equalTo(view);
            make.height.mas_equalTo(1.0);
        }];
    }
    
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [button addTarget:self action:@selector(clickPdfSizeButton:) forControlEvents:(UIControlEventTouchUpInside)];
    button.tag = pdfSize;
    [view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    [self.pageSizeButtons addObject:button];
    return view;
}

- (void)clickPdfSizeButton:(UIButton *)button {
    self.currentPdfSize = button.tag;
    
    if (self.SelectPdfSizeBlock) {
        self.SelectPdfSizeBlock(self.currentPdfSize,self.currentOrientation);
    }
    
    [self updatePdfSizeSelectImageView];
}

#pragma mark -lazy
- (HZBaseNavigationBar *)navBar {
    if (!_navBar) {
        _navBar = [[HZBaseNavigationBar alloc] init];
        [_navBar configBackImage:[UIImage imageNamed:@"rose_back"]];
        [_navBar configTitle:NSLocalizedString(@"str_pagesize", nil)];
        [_navBar configRightTitle:nil];
        
        @weakify(self);
        _navBar.clickBackBlock = ^{
            @strongify(self);
            [self dismissViewControllerAnimated:YES completion:nil];
        };
    }
    return _navBar;
}

@end
