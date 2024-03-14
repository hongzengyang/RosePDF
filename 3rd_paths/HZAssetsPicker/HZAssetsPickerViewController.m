//
//  HZAssetsPickerViewController.m
//  RosePDF
//
//  Created by THS on 2024/2/7.
//

#import "HZAssetsPickerViewController.h"
#import <Photos/Photos.h>
#import "HZAssetsPickerNavigationBar.h"
#import <HZUIKit/HZUIKit.h>
#import <HZFoundationKit/HZFoundationKit.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>
#import "HZAssetsPickerManager.h"
#import "HZCurrentAlbumView.h"
#import "HZAssetsPickerCell.h"
#import "HZAssetsPickerBottomView.h"
#import "HZAlbumPickerViewController.h"
#import "HZCameraViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface HZAssetsPickerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) HZAssetsPickerNavigationBar *navBar;
@property (nonatomic, strong) HZCurrentAlbumView *curAlbumView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) HZAssetsPickerBottomView *bottomView;

@property (nonatomic, strong) HZAssetsPickerManager *databoard;

@property (nonatomic, assign) BOOL requesting;

@end

@implementation HZAssetsPickerViewController
- (void)dealloc {
    [self.databoard clean];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDarkContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configView];
    
    [self requestData];
}

- (void)viewDidAppear:(BOOL)animated {
    // 检查相册权限状态
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    // 判断权限状态
    if (status == PHAuthorizationStatusLimited) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"str_photo_permission_limit_title", nil)
                                                                                 message:NSLocalizedString(@"str_photo_permission_limit_tip", nil)
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"str_cancel", nil) style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"str_go_setting", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 跳转到应用设置页面
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                               options:@{}
                                     completionHandler:nil];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:settingsAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)configView {
    self.view.backgroundColor = [UIColor hz_getColor:@"F2F1F6"];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.navBar];
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(self.view);
        make.height.mas_equalTo([UIView hz_safeTop] + 44);
    }];
    
    [self.view addSubview:self.curAlbumView];
    [self.curAlbumView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(32);
        make.top.equalTo(self.navBar.mas_bottom).offset(8);
    }];
    
    [self.view addSubview:self.bottomView];
}

#pragma mark - Data
- (void)requestData {
    @weakify(self);
    [HZAssetsPickerManager requestAuthorizationWithCompleteBlock:^(BOOL complete) {
        @strongify(self);
        if (!complete) {//用户拒绝
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"str_photo_permission_deny_title", nil)
                                                                                     message:NSLocalizedString(@"str_photo_permission_deny_tip", nil)
                                                                              preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"str_cancel", nil) style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"str_go_setting", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                // 跳转到应用设置页面
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                                   options:@{}
                                         completionHandler:nil];
            }];

            [alertController addAction:cancelAction];
            [alertController addAction:settingsAction];

            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
        
        [self.databoard requestCurrentAlbumWithCompleteBlock:^(BOOL complete) {
            @strongify(self);
            [self.curAlbumView updateWithAlbum:self.databoard.currentAlbum];
            [self.collectionView reloadData];
        }];
    }];
}

#pragma mark - UIScrollView
static CGFloat prevOffsetY = 0;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat value = -([UIView hz_safeTop] + 44);
    if (scrollView.contentOffset.y >= value && prevOffsetY < value) {
        [self.navBar configSwipeUpMode:YES];
    }else if (scrollView.contentOffset.y <= value && prevOffsetY > value) {
        [self.navBar configSwipeUpMode:NO];
    }
    prevOffsetY = scrollView.contentOffset.y;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.databoard.assetsList.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HZAssetsPickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HZAssetsPickerCell" forIndexPath:indexPath];
    HZAsset *asset = [self.databoard.assetsList objectAtIndex:indexPath.row];
    [cell configAsset:asset];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (self.view.width - self.collectionView.contentInset.left - self.collectionView.contentInset.right - 6 - 6) / 3.0;
    return CGSizeMake(width, width);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 6;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    HZAsset *asset = [self.databoard.assetsList objectAtIndex:indexPath.row];
    if (asset.isCameraEntrance) {
        @weakify(self);
        void(^enterCameraBlock)(NSArray <UIImage *>*) = ^(NSArray <UIImage *>*images){
            @strongify(self);
            NSDictionary *param;
            if (images.count > 0) {
                param = @{@"images":[images copy]};
            }
            HZCameraViewController *vc = [[HZCameraViewController alloc] initWithInputParams:param];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:vc animated:YES completion:nil];
            
            vc.selectFinishBlock = ^(NSArray<UIImage *> *images) {
                @strongify(self);
                [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    HZAsset *asset = [[HZAsset alloc] initWithImage:obj];
                    asset.captureTime = obj.createTime;
                    asset.captureTitle = obj.title;
                    [self.databoard addAsset:asset];
                }];
                [self.bottomView reload];
                [self.navBar updateNextButtonEnable:self.databoard.selectedAssets.count > 0];
            };
        };
        
        if (self.databoard.selectedAssets.count == 0) {
            enterCameraBlock(nil);
            return;
        }
        
        NSMutableArray <UIImage *>*thumbImages = [[NSMutableArray alloc] init];
        dispatch_queue_t queue = dispatch_queue_create("com.sbpdf.requestThumbnail", NULL);
        dispatch_async(queue, ^{
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            __block NSInteger callbackCount = 0;
            for (int i = 0; i < self.databoard.selectedAssets.count; i++) {
                CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();
                NSLog(@"debug--开始刷新第%d页page,startTime:%lf",i,startTime);
                HZAsset *asset = self.databoard.selectedAssets[i];
                [asset requestThumbnailWithCompleteBlock:^(UIImage * _Nonnull image) {
                    @strongify(self);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        CFTimeInterval endTime = CFAbsoluteTimeGetCurrent();
                        NSLog(@"debug--完成刷新第%d页page,endTime:%lf",i,(endTime - startTime));
                        dispatch_semaphore_signal(semaphore);
                        callbackCount++;
                        [thumbImages addObject:image];
                        if (callbackCount == self.databoard.selectedAssets.count) {
                            enterCameraBlock([thumbImages copy]);
                        }
                    });
                }];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
        });
        return;
    }
    
    BOOL alreadySelected = [self.databoard isSelected:asset];
    if (alreadySelected) {
        [self.databoard deleteAsset:asset];
    }else {
        [self.databoard addAsset:asset];
    }
    [self.navBar updateNextButtonEnable:self.databoard.selectedAssets.count > 0];
    [self.bottomView reload];
}


#pragma mark - Lazy
- (HZAssetsPickerNavigationBar *)navBar {
    if (!_navBar) {
        _navBar =[[HZAssetsPickerNavigationBar alloc] init];
        [_navBar configBackImage:[UIImage imageNamed:@"rose_close"]];
        [_navBar configRightTitle:NSLocalizedString(@"str_next", nil)];
        [_navBar configTitle:NSLocalizedString(@"str_import", nil)];
        [_navBar updateNextButtonEnable:NO];
        @weakify(self);
        _navBar.clickBackBlock = ^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
            [self.databoard clean];
        };
        _navBar.clickRightBlock = ^{
            @strongify(self);
            if (self.databoard.selectedAssets.count == 0) {
                return;
            }
            if (self.requesting) {
                return;
            }
            [SVProgressHUD show];
            [self.databoard requestHighQualityImagesWithCompleteBlock:^(NSArray<UIImage *> *images) {
                [SVProgressHUD dismiss];
                @strongify(self);
                if (self.SelectImageBlock) {
                    self.SelectImageBlock(images);
                }
                self.requesting = NO;
            }];
            self.requesting = YES;
        };
    }
    return _navBar;
}

- (HZCurrentAlbumView *)curAlbumView {
    if (!_curAlbumView) {
        _curAlbumView = [[HZCurrentAlbumView alloc] init];
        @weakify(self);
        _curAlbumView.ClickBlock = ^{
            @strongify(self);
            HZAlbumPickerViewController *vc = [[HZAlbumPickerViewController alloc] initWithDataboard:self.databoard];
            vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [self presentViewController:vc animated:YES completion:nil];
            vc.SelectAlbum = ^(HZAlbum *album) {
                @strongify(self);
                [self.databoard selectAlbum:album];
                [self requestData];
            };
        };
    }
    return _curAlbumView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[HZAssetsPickerCell class] forCellWithReuseIdentifier:@"HZAssetsPickerCell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _collectionView.contentInset = UIEdgeInsetsMake([UIView hz_safeTop] + 44 + 48, 19, 200, 19);
    }
    return _collectionView;
}

- (HZAssetsPickerBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[HZAssetsPickerBottomView alloc] initWithFrame:CGRectMake(0, self.view.height, self.view.width, [UIView hz_safeBottom] + 53 + 80) databoard:self.databoard];
        @weakify(self);
        _bottomView.deleteAllBlock = ^{
            @strongify(self);
            [self.databoard deleAllAssets];
            [self.bottomView reload];
            [self.navBar updateNextButtonEnable:self.databoard.selectedAssets.count > 0];
        };
        _bottomView.deleteAeestBlock = ^(HZAsset *asset) {
            @strongify(self);
            [self.databoard deleteAsset:asset];
            [self.bottomView reload];
            [self.navBar updateNextButtonEnable:self.databoard.selectedAssets.count > 0];
        };
    }
    return _bottomView;
}

- (HZAssetsPickerManager *)databoard {
    if (!_databoard) {
        _databoard = [[HZAssetsPickerManager alloc] init];
    }
    return _databoard;
}

@end
