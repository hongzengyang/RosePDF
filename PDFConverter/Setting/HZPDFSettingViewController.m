//
//  HZPDFSettingViewController.m
//  RosePDF
//
//  Created by hzy on 2024-02-19.
//

#import "HZPDFSettingViewController.h"
#import "HZCommonHeader.h"
#import "HZProjectManager.h"
#import "HZBaseNavigationBar.h"
#import "HZPDFSettingCell.h"
#import "HZPDFSettingTitleView.h"
#import "HZPDFSettingPasswordView.h"
#import "HZPDFSettingMarginView.h"
#import "HZPDFSettingQualityView.h"
#import "HZPDFSettingSizeView.h"
#import "HZPDFSizeViewController.h"
#import "HZPDFMaker.h"
#import "HZPDFSettingDataboard.h"
#import "HZPDFPreviewViewController.h"
#import "HZPDFConvertingView.h"
#import "HZIAPManager.h"
#import "HZIAPViewController.h"

#define pref_key_click_convert_count   @"pref_key_click_convert_count"

@interface HZPDFSettingViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) HZPDFSettingDataboard *databoard;

@property (nonatomic,strong) HZBaseNavigationBar *navBar;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *placeHolderView;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) HZPDFSettingTitleView *titleView;
@property (nonatomic, strong) HZPDFSettingPasswordView *passwordView;
@property (nonatomic, strong) HZPDFSettingMarginView *marginView;
@property (nonatomic, strong) HZPDFSettingQualityView *qualityView;
@property (nonatomic, strong) HZPDFSettingSizeView *sizeView;

@property (nonatomic, assign) BOOL convertingPdf;
@property (nonatomic, strong) HZPDFConvertingView *convertingView;

@end

@implementation HZPDFSettingViewController

- (BOOL)prefersStatusBarHidden {
    if (self.convertingPdf) {
        return YES;
    }else {
        return NO;
    }
}

- (instancetype)initWithProject:(HZProjectModel *)project originalProject:(HZProjectModel *)originalProject {
    if (self = [super init]) {
        self.databoard.project = project;
        self.databoard.originalProject = originalProject;
        
        NSString *pdfPath = [project pdfPath];
        if ([HZProjectManager isTmp:project.identifier]) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:pdfPath]) {
                [[NSFileManager defaultManager] removeItemAtPath:pdfPath error:nil];
            }
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)configView {
    self.view.backgroundColor = hz_1_bgColor;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    {
        //placeHolderView
        self.placeHolderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, hz_safeTop + navigationHeight)];
        [self.scrollView addSubview:self.placeHolderView];
        
        //CollectionView
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.placeHolderView.bottom, self.view.width, 177) collectionViewLayout:layout];
        self.collectionView.backgroundColor = [UIColor whiteColor];
        self.collectionView.showsHorizontalScrollIndicator = NO;
        [self.collectionView registerClass:[HZPDFSettingCell class] forCellWithReuseIdentifier:@"HZPDFSettingCell"];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.contentInset = UIEdgeInsetsMake(16, 16, 16, 16);
        [self.scrollView addSubview:self.collectionView];
        
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(16, self.collectionView.bottom + 16, self.view.width - 32, 0)];
        self.containerView.backgroundColor = [UIColor whiteColor];
        self.containerView.layer.cornerRadius = 10;
        self.containerView.layer.masksToBounds = YES;
        [self.scrollView addSubview:self.containerView];
        
        //title
        self.titleView = [[HZPDFSettingTitleView alloc] initWithFrame:CGRectMake(0, 0, self.containerView.width, 70) inputText:self.databoard.project.title];
        [self.containerView addSubview:self.titleView];
        //password
        self.passwordView = [[HZPDFSettingPasswordView alloc] initWithFrame:CGRectMake(0, self.titleView.bottom, self.containerView.width, 0) databoard:self.databoard];
        @weakify(self);
        self.passwordView.PasswordSwitchBlock = ^{
            @strongify(self);
            [self layoutAllView];
        };
        [self.containerView addSubview:self.passwordView];
        //margin
        self.marginView = [[HZPDFSettingMarginView alloc] initWithFrame:CGRectMake(0, self.passwordView.bottom, self.containerView.width, 70) databoard:self.databoard];
        [self.containerView addSubview:self.marginView];
        //quality
        self.qualityView = [[HZPDFSettingQualityView alloc] initWithFrame:CGRectMake(0, self.marginView.bottom, self.containerView.width, 70) databoard:self.databoard];
        [self.containerView addSubview:self.qualityView];
        //size
        self.sizeView = [[HZPDFSettingSizeView alloc] initWithFrame:CGRectMake(0, self.qualityView.bottom, self.containerView.width, 70) databoard:self.databoard];
        [self.containerView addSubview:self.sizeView];
        
        [self layoutAllView];
    }
    
    [self.view addSubview:self.navBar];
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(self.view);
        make.height.mas_equalTo(hz_safeTop + navigationHeight);
    }];
    
    UIButton *previewBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.view addSubview:previewBtn];
    [previewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(16);
        make.bottom.equalTo(self.view).offset(-hz_safeBottom - 20);
        make.width.height.mas_equalTo(56);
    }];
    previewBtn.backgroundColor = hz_2_bgColor;
    previewBtn.layer.cornerRadius = 10;
    previewBtn.contentMode = UIViewContentModeCenter;
    [previewBtn setImage:[UIImage imageNamed:@"rose_setting_preview"] forState:(UIControlStateNormal)];
    [previewBtn addTarget:self action:@selector(clickPreviewButton) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIButton *convertBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.view addSubview:convertBtn];
    [convertBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view).offset(-16);
        make.bottom.equalTo(previewBtn);
        make.height.mas_equalTo(56);
        if ([[HZSystemManager manager] iPadDevice]) {
            make.leading.equalTo(previewBtn.mas_trailing).offset(133);
        }else {
            make.leading.equalTo(previewBtn.mas_trailing).offset(33);
        }
    }];
    convertBtn.layer.cornerRadius = 16;
    convertBtn.layer.masksToBounds=  YES;
    [convertBtn setBackgroundImage:[UIImage imageNamed:@"rose_big_gradient_bg"] forState:(UIControlStateNormal)];
    [convertBtn setBackgroundImage:[UIImage imageNamed:@"rose_big_gradient_bg"] forState:(UIControlStateHighlighted)];
    [convertBtn setTitle:NSLocalizedString(@"str_convert", nil) forState:(UIControlStateNormal)];
    convertBtn.titleLabel.font = [UIFont systemFontOfSize:17 weight:(UIFontWeightSemibold)];
    [convertBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [convertBtn addTarget:self action:@selector(clickConvertButton) forControlEvents:(UIControlEventTouchUpInside)];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)layoutAllView {
    [self.passwordView layoutAllViews];
    [self.marginView setTop:self.passwordView.bottom];
    [self.qualityView setTop:self.marginView.bottom];
    [self.sizeView setTop:self.qualityView.bottom];
    
    [self.containerView setHeight:self.sizeView.bottom];
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.width, self.containerView.bottom + 120)];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma 键盘
//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)note {
    //取出键盘最终的frame
    CGRect rect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSLog(@"debug-%@",NSStringFromCGRect(rect));
    
    CGRect convert = [self.passwordView.superview convertRect:self.passwordView.frame toView:self.view];
    CGFloat pswBottom = convert.origin.y + 115.0;
    if (rect.origin.y < pswBottom) {
        //取出键盘弹出需要花费的时间
        double duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, pswBottom - rect.origin.y) animated:YES];
    }
    
}
- (void)keyboardWillHide:(NSNotification *)note {
    double duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, 0) animated:YES];
}

#pragma mark - Click
- (void)clickPreviewButton {
    [self updateInfo];
    HZPDFPreviewViewController *vc = [[HZPDFPreviewViewController alloc] initWithProject:self.databoard.project];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)clickConvertButton {
    BOOL openPsw = [self.passwordView openPswState];
    NSString *psw = [self.passwordView curPsw];
    if (openPsw) {
        if (![HZCommonUtils validPassword:psw]) {
            [SVProgressHUD showImage:nil status:NSLocalizedString(@"str_password_format_error", nil)];
            return;
        }
    }
    
    {//vip
        if (![IAPInstance isVip]) {
            id count = [[NSUserDefaults standardUserDefaults] valueForKey:pref_key_click_convert_count];
            if ([count integerValue] == 1) {
                HZIAPViewController *vc = [[HZIAPViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
                
                @weakify(self);
                vc.clickCloseBlock = ^{
                    @strongify(self);
                    [self.navigationController popViewControllerAnimated:YES];
                };
                vc.successBlock = ^{
                    @strongify(self);
                    [self.navigationController popViewControllerAnimated:YES];
                };
                return;
            }
        }
    }
    
    
    __block NSTimeInterval startTime = CFAbsoluteTimeGetCurrent();
    __block NSTimeInterval endTime;
    
    @weakify(self);
    void(^MigrateBlock)(void) = ^{
        @strongify(self);
        [HZProjectManager migratePagesFromProject:self.databoard.project toProject:self.databoard.originalProject keepOrigin:NO completeBlock:^(HZProjectModel *project) {
            @strongify(self);
            endTime = CFAbsoluteTimeGetCurrent();
            CGFloat duration = endTime - startTime;
            if (duration < 1.5) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((1.5 - duration) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.convertingView completeConvertingWithBlock:^{
                        @strongify(self);
                        self.convertingPdf = NO;
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }];
                });
            }else {
                [self.convertingView completeConvertingWithBlock:^{
                    @strongify(self);
                    self.convertingPdf = NO;
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }];
            }
        }];
    };
    
    [self updateInfo];
    [HZPDFMaker generatePDFWithProject:self.databoard.project completeBlock:^(NSString *pdfPath) {
        @strongify(self);
        MigrateBlock();
    }];
    self.convertingPdf = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    [self showConvertingLoading];
    
    id count = [[NSUserDefaults standardUserDefaults] valueForKey:pref_key_click_convert_count];
    NSInteger number = 0;
    if (count) {
        number = [count integerValue];
    }
    number++;
    [[NSUserDefaults standardUserDefaults] setValue:@(number) forKey:pref_key_click_convert_count];
}

- (void)updateInfo {
    NSString *title = [self.titleView currentTitle];
    BOOL openPsw = [self.passwordView openPswState];
    NSString *psw = [self.passwordView curPsw];
    HZPDFMargin margin = [self.marginView currentMargin];
    HZPDFQuality quality = [self.qualityView currentQuality];
    HZPDFSize pdfSize = [self.sizeView currentPdfSize];
    
    HZProjectModel *project = self.databoard.project;
    if (title.length > 0) {
        project.title = title;
    }
    project.openPassword = openPsw;
    project.password = psw;
    project.margin = margin;
    project.quality = quality;
    project.pdfSize = pdfSize;
}

- (void)showConvertingLoading {
    if (!self.convertingView) {
        self.convertingView = [[HZPDFConvertingView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:self.convertingView];
    }
    [self.view bringSubviewToFront:self.convertingView];
    
    [self.convertingView startConverting];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.databoard.project.pageModels.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HZPDFSettingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HZPDFSettingCell" forIndexPath:indexPath];
    HZPageModel *pageModel = [self.databoard.project.pageModels objectAtIndex:indexPath.row];
    [cell configWithModel:pageModel];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {//116 145
    CGFloat height = self.collectionView.height - self.collectionView.contentInset.top - self.collectionView.contentInset.bottom;
    CGFloat width = 116.0 / 145.0 * height;
    return CGSizeMake(width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 16;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark -lazy
- (HZPDFSettingDataboard *)databoard {
    if (!_databoard) {
        _databoard = [[HZPDFSettingDataboard alloc] init];
    }
    return _databoard;
}
- (HZBaseNavigationBar *)navBar {
    if (!_navBar) {
        _navBar = [[HZBaseNavigationBar alloc] init];
        [_navBar configBackImage:[UIImage imageNamed:@"rose_back"]];
        [_navBar configTitle:NSLocalizedString(@"str_convert", nil)];
        [_navBar configRightTitle:nil];
        
        @weakify(self);
        _navBar.clickBackBlock = ^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        };
    }
    return _navBar;
}

@end
