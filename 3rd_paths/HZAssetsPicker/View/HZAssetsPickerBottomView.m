//
//  HZAssetsPickerBottomView.m
//  HZAssetsPicker
//
//  Created by THS on 2024/2/18.
//

#import "HZAssetsPickerBottomView.h"
#import <HZUIKit/HZUIKit.h>
#import <Masonry/Masonry.h>
#import "HZAssetsPickerBottomCell.h"
#import "HZAssetsPickerManager.h"

@interface HZAssetsPickerBottomView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UILabel *selectLab;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) HZAssetsPickerManager *databoard;

@end

@implementation HZAssetsPickerBottomView


- (instancetype)initWithFrame:(CGRect)frame databoard:(HZAssetsPickerManager *)databoard {
    if (self = [super initWithFrame:frame]) {
        self.databoard = databoard;
        [self configView];
    }
    return self;
}

- (void)configView {
    self.backgroundColor = [UIColor clearColor];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [self addSubview:blurEffectView];
    [blurEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    UIButton *deleteAllBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [deleteAllBtn setImage:[UIImage imageNamed:@"rose_asset_deleteAll"] forState:(UIControlStateNormal)];
    [deleteAllBtn addTarget:self action:@selector(clickDeleteAll) forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:deleteAllBtn];
    [deleteAllBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(self).offset(16);
        make.width.height.mas_equalTo(22);
    }];
    
    self.selectLab = [[UILabel alloc] init];
    self.selectLab.font = [UIFont systemFontOfSize:17];
    self.selectLab.textColor = [UIColor hz_getColor:@"333333"];
    [self addSubview:self.selectLab];
    [self.selectLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(deleteAllBtn.mas_trailing).offset(15);
        make.centerY.equalTo(deleteAllBtn);
    }];
    
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.top.equalTo(self).offset(53);
        make.height.mas_equalTo(80);
    }];
    
    [self hz_addCorner:(UIRectCornerTopLeft | UIRectCornerTopRight) radious:16];
}

- (void)reload {
    [self.collectionView reloadData];
    
    CGFloat curY = self.top;
    NSInteger selectCount = self.databoard.selectedAssets.count;
    if (selectCount == 0) {
        if (curY == [UIScreen mainScreen].bounds.size.height) {
            
        }else {
            [UIView animateWithDuration:0.1 animations:^{
                [self setTop:[UIScreen mainScreen].bounds.size.height];
            }];
        }
    }else {
        if (curY == [UIScreen mainScreen].bounds.size.height) {
            [UIView animateWithDuration:0.1 animations:^{
                [self setTop:[UIScreen mainScreen].bounds.size.height - self.height];
            }];
        }else {

        }
    }
    
    self.selectLab.text = [NSString stringWithFormat:NSLocalizedString(@"str_selected_photos", nil),@(selectCount)];
}

- (void)clickDeleteAll {
    if (self.deleteAllBlock) {
        self.deleteAllBlock();
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.databoard.selectedAssets.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HZAssetsPickerBottomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HZAssetsPickerBottomCell" forIndexPath:indexPath];
    HZAsset *asset = [self.databoard.selectedAssets objectAtIndex:indexPath.row];
    [cell configWithAsset:asset];
    
    __weak typeof(self) weakSelf = self;
    cell.clickDeleteBlock = ^(HZAsset *asset) {
        if (weakSelf.deleteAeestBlock) {
            weakSelf.deleteAeestBlock(asset);
        }
    };
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80.0, 80.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - Lazy
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[HZAssetsPickerBottomCell class] forCellWithReuseIdentifier:@"HZAssetsPickerBottomCell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.contentInset = UIEdgeInsetsMake(0, 10, 0, 10);
    }
    return _collectionView;
}

@end
