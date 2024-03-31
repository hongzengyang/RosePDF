//
//  HZCropViewController.m
//  RosePDF
//
//  Created by THS on 2024/3/6.
//

#import "HZCropViewController.h"
#import "HZCommonHeader.h"
#import "HZCropData.h"
#import "HZBaseNavigationBar.h"
#import "HZCropCell.h"

@interface HZCropViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSArray <HZCropData *>*dataList;

@property (nonatomic, strong) HZBaseNavigationBar *navBar;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation HZCropViewController
- (instancetype)initWithPageModel:(HZPageModel *)pageModel {
    if (self = [super init]) {
        HZCropData *cropData = [[HZCropData alloc] initWithPage:pageModel];
        self.dataList = @[cropData];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configView];
}

- (void)configView {
    [self.view addSubview:self.navBar];
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(self.view);
        make.height.mas_equalTo(hz_safeTop + navigationHeight);
    }];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navBar.mas_bottom).offset(0);
        make.leading.equalTo(self.view).offset(0);
        make.trailing.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view).offset(-hz_safeBottom);
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataList.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HZCropCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HZCropCell" forIndexPath:indexPath];
    HZCropData *data = [self.dataList objectAtIndex:indexPath.row];
    [cell configWithData:data];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - Finish
- (void)handleFinishAction {
    [SVProgressHUD show];
    dispatch_queue_t queue = dispatch_queue_create("com.sbpdf.applyCropper", NULL);
    dispatch_async(queue, ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        __block NSInteger callbackCount = 0;
        @weakify(self);
        for (int i = 0; i < self.dataList.count; i++) {
            HZCropData *data = self.dataList[i];
            data.pageModel.borderArray = [data.borders copy];
            [data.pageModel cropWithCompleteBlock:^{
                @strongify(self);
                dispatch_semaphore_signal(semaphore);
                callbackCount++;
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    if (callbackCount == self.dataList.count) {
                        [SVProgressHUD dismiss];
                        if (self.cropFinishBlock) {
                            self.cropFinishBlock();
                        }
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                });
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
    });
}

#pragma mark - lazy
- (HZBaseNavigationBar *)navBar {
    if (!_navBar) {
        _navBar = [[HZBaseNavigationBar alloc] init];
        [_navBar configBackImage:[UIImage imageNamed:@"rose_back"]];
        [_navBar configTitle:NSLocalizedString(@"str_crop", nil)];
        [_navBar configRightTitle:NSLocalizedString(@"str_done", nil)];
        
        @weakify(self);
        _navBar.clickBackBlock = ^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        };
        
        _navBar.clickRightBlock = ^{
            @strongify(self);
            [self handleFinishAction];
        };
    }
    return _navBar;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[HZCropCell class] forCellWithReuseIdentifier:@"HZCropCell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

@end
