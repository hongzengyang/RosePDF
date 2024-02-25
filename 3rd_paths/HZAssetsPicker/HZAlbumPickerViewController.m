//
//  HZAlbumPickerViewController.m
//  HZAssetsPicker
//
//  Created by THS on 2024/2/18.
//

#import "HZAlbumPickerViewController.h"
#import <Photos/Photos.h>
#import "HZAssetsPickerNavigationBar.h"
#import <HZUIKit/HZUIKit.h>
#import <HZFoundationKit/HZFoundationKit.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>
#import "HZAssetsPickerManager.h"
#import "HZAlbumPickerCell.h"

@interface HZAlbumPickerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) HZAssetsPickerNavigationBar *navBar;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray <HZAlbum *>*albumList;

@property (nonatomic, strong) HZAssetsPickerManager *databoard;

@end

@implementation HZAlbumPickerViewController

- (instancetype)initWithDataboard:(HZAssetsPickerManager *)databoard {
    if (self = [super init]) {
        self.databoard = databoard;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configView];
    [self requestData];
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
}

- (void)requestData {
    self.albumList = [self.databoard.albumsList copy];
    [self.collectionView reloadData];
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
    return self.albumList.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HZAlbumPickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HZAlbumPickerCell" forIndexPath:indexPath];
    HZAlbum *album = [self.albumList objectAtIndex:indexPath.row];
    [cell configWithAlbum:album];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (self.view.width - self.collectionView.contentInset.left - self.collectionView.contentInset.right - 22) / 2.0;
    return CGSizeMake(width, width + 5 + 19 + 5 + 12);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 6;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    HZAlbum *album = [self.albumList objectAtIndex:indexPath.row];
    if (self.SelectAlbum) {
        self.SelectAlbum(album);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Lazy
- (HZAssetsPickerNavigationBar *)navBar {
    if (!_navBar) {
        _navBar =[[HZAssetsPickerNavigationBar alloc] init];
        [_navBar configBackImage:[UIImage imageNamed:@"rose_close"]];
        [_navBar configRightTitle:nil];
        [_navBar configTitle:NSLocalizedString(@"str_import", nil)];
        @weakify(self);
        _navBar.clickBackBlock = ^{
            @strongify(self);
            [self dismissViewControllerAnimated:YES completion:nil];
        };
    }
    return _navBar;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[HZAlbumPickerCell class] forCellWithReuseIdentifier:@"HZAlbumPickerCell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _collectionView.contentInset = UIEdgeInsetsMake([UIView hz_safeTop] + 44 + 16, 19, 200, 19);
    }
    return _collectionView;
}

@end
