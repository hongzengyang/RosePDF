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
@property (nonatomic, assign) HZPDFSize currentPdfSize;

@property (nonatomic, strong) HZBaseNavigationBar *navBar;
@property (nonatomic, strong) UIImageView *selectImageView;

@property (nonatomic, strong) NSMutableArray <UIButton *>*buttons;

@end

@implementation HZPDFSizeViewController

- (instancetype)initWithInputPDFSize:(HZPDFSize)pdfSize {
    if (self = [super init]) {
        self.currentPdfSize = pdfSize;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.buttons = [[NSMutableArray alloc] init];
    [self configView];
}

- (void)configView {
    [self.view addSubview:self.navBar];
    self.navBar.backgroundColor = [UIColor clearColor];
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(self.view);
        make.height.mas_equalTo(hz_safeTop + navigationHeight);
    }];
    
    UILabel *titleLab = [[UILabel alloc] init];
    [self.view addSubview:titleLab];
    titleLab.font = [UIFont systemFontOfSize:14];
    titleLab.textColor = hz_getColor(@"888888");
    titleLab.text = NSLocalizedString(@"str_pagesize", nil);
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(32);
        make.top.equalTo(self.navBar.mas_bottom).offset(44);
    }];
    
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.layer.cornerRadius = 10;
    containerView.layer.masksToBounds = YES;
    [self.view addSubview:containerView];
    
    UIView *autoFit = [self createItemViewWithPdfSize:(HZPDFSize_autoFit) addSeparater:YES width:self.view.width - 32];
    [containerView addSubview:autoFit];
    [autoFit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(containerView);
        make.top.equalTo(containerView);
        make.height.mas_equalTo(56);
    }];
    UIView *A3 = [self createItemViewWithPdfSize:(HZPDFSize_A3) addSeparater:YES width:self.view.width - 32];
    [containerView addSubview:A3];
    [A3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(containerView);
        make.top.equalTo(autoFit.mas_bottom);
        make.height.mas_equalTo(56);
    }];
    UIView *A4 = [self createItemViewWithPdfSize:(HZPDFSize_A4) addSeparater:YES width:self.view.width - 32];
    [containerView addSubview:A4];
    [A4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(containerView);
        make.top.equalTo(A3.mas_bottom);
        make.height.mas_equalTo(56);
    }];
    UIView *A5 = [self createItemViewWithPdfSize:(HZPDFSize_A5) addSeparater:YES width:self.view.width - 32];
    [containerView addSubview:A5];
    [A5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(containerView);
        make.top.equalTo(A4.mas_bottom);
        make.height.mas_equalTo(56);
    }];
    UIView *B4 = [self createItemViewWithPdfSize:(HZPDFSize_B4) addSeparater:YES width:self.view.width - 32];
    [containerView addSubview:B4];
    [B4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(containerView);
        make.top.equalTo(A5.mas_bottom);
        make.height.mas_equalTo(56);
    }];
    UIView *B5 = [self createItemViewWithPdfSize:(HZPDFSize_B5) addSeparater:YES width:self.view.width - 32];
    [containerView addSubview:B5];
    [B5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(containerView);
        make.top.equalTo(B4.mas_bottom);
        make.height.mas_equalTo(56);
    }];
    UIView *Executive = [self createItemViewWithPdfSize:(HZPDFSize_Executive) addSeparater:YES width:self.view.width - 32];
    [containerView addSubview:Executive];
    [Executive mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(containerView);
        make.top.equalTo(B5.mas_bottom);
        make.height.mas_equalTo(56);
    }];
    UIView *Legal = [self createItemViewWithPdfSize:(HZPDFSize_Legal) addSeparater:YES width:self.view.width - 32];
    [containerView addSubview:Legal];
    [Legal mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(containerView);
        make.top.equalTo(Executive.mas_bottom);
        make.height.mas_equalTo(56);
    }];
    UIView *Letter = [self createItemViewWithPdfSize:(HZPDFSize_Letter) addSeparater:NO width:self.view.width - 32];
    [containerView addSubview:Letter];
    [Letter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(containerView);
        make.top.equalTo(Legal.mas_bottom);
        make.height.mas_equalTo(56);
    }];
    
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(16);
        make.trailing.equalTo(self.view).offset(-16);
        make.bottom.equalTo(Letter.mas_bottom);
        make.top.equalTo(titleLab.mas_bottom).offset(10);
    }];
    
    self.selectImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rose_pdf_size_select"]];
    self.selectImageView.contentMode = UIViewContentModeCenter;
    [containerView addSubview:self.selectImageView];
    [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(containerView).offset(-14);
        make.width.height.mas_equalTo(22);
    }];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    [self updateSelectImageView];
}

- (void)updateSelectImageView {
    [self.buttons enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == self.currentPdfSize) {
            self.selectImageView.centerY = obj.superview.centerY;
        }
    }];
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
    [button addTarget:self action:@selector(clickButton:) forControlEvents:(UIControlEventTouchUpInside)];
    button.tag = pdfSize;
    [view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    [self.buttons addObject:button];
    return view;
}

- (void)clickButton:(UIButton *)button {
    self.currentPdfSize = button.tag;
    
    if (self.SelectPdfSizeBlock) {
        self.SelectPdfSizeBlock(self.currentPdfSize);
    }
    
    [self updateSelectImageView];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -lazy
- (HZBaseNavigationBar *)navBar {
    if (!_navBar) {
        _navBar = [[HZBaseNavigationBar alloc] init];
        [_navBar configBackImage:[UIImage imageNamed:@"rose_back"]];
        [_navBar configTitle:NSLocalizedString(@"str_settings", nil)];
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
