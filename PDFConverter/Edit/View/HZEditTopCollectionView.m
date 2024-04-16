//
//  HZEditTopCollectionView.m
//  RosePDF
//
//  Created by THS on 2024/2/6.
//

#import "HZEditTopCollectionView.h"
#import "HZCommonHeader.h"
#import "HZEditTopCell.h"
#import <HZAssetsPicker/HZAssetsPickerViewController.h>
#import "HZProjectManager.h"

@interface HZEditTopCollectionView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) HZEditDataboard *databoard;

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation HZEditTopCollectionView
- (instancetype)initWithDataboard:(HZEditDataboard *)databoard {
    if (self = [super init]) {
        self.databoard = databoard;
        [self configView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleIndexChanged) name:pref_key_scroll_preview object:nil];
        
        [self reloadAll];
    }
    return self;
}
- (void)configView {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)reloadAll {
    [self.collectionView reloadData];
    [self.collectionView performBatchUpdates:nil completion:^(BOOL finished) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.databoard.currentIndex inSection:0] atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:YES];
    }];
}

- (void)reloadCurrent {
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.databoard.currentIndex inSection:0]]];
    [self.collectionView performBatchUpdates:nil completion:^(BOOL finished) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.databoard.currentIndex inSection:0] atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:YES];
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.databoard.project.pageModels.count + 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HZEditTopCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HZEditTopCell" forIndexPath:indexPath];
    if (indexPath.row == self.databoard.project.pageModels.count) {
        [cell configWithModel:nil isAdd:YES];
        [cell configSelected:NO];
    }else {
        HZPageModel *pageModel = [self.databoard.project.pageModels objectAtIndex:indexPath.row];
        [cell configWithModel:pageModel isAdd:NO];
        [cell configSelected:indexPath.row == self.databoard.currentIndex];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(56.0, 56.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 16;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.databoard.project.pageModels.count) {
        HZAssetsPickerViewController *assetPicker = [[HZAssetsPickerViewController alloc] init];
        @weakify(self);
        assetPicker.SelectImageBlock = ^(NSArray<UIImage *> * _Nonnull images) {
            @strongify(self);
            if (images.count == 0) {
                [[UIView hz_viewController].navigationController popViewControllerAnimated:YES];
                return;
            }
            [SVProgressHUD show];
            [HZProjectManager addPagesWithImages:images inProject:self.databoard.project completeBlock:^(NSArray<HZPageModel *> *pages) {
                @strongify(self);
                [SVProgressHUD dismiss];
                [[NSNotificationCenter defaultCenter] postNotificationName:pref_key_add_assets_finished object:nil];
                [[UIView hz_viewController].navigationController popViewControllerAnimated:YES];
            }];
        };
        [[UIView hz_viewController].navigationController pushViewController:assetPicker animated:YES];
        return;
    }
    
    if (self.databoard.currentIndex != indexPath.row) {
        self.databoard.currentIndex = indexPath.row;
        [self handleIndexChanged];
        [[NSNotificationCenter defaultCenter] postNotificationName:pref_key_click_edit_top object:nil];
    }
}

#pragma mark - Notification
- (void)handleIndexChanged {
    [self.collectionView reloadData];
    [self.collectionView performBatchUpdates:nil completion:^(BOOL finished) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.databoard.currentIndex inSection:0] atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:YES];
    }];
}

#pragma mark - Lazy
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                             collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[HZEditTopCell class] forCellWithReuseIdentifier:@"HZEditTopCell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        if (isRTL) {
            _collectionView.contentInset = UIEdgeInsetsMake(16, 16+87, 16, 16);
        }else {
            _collectionView.contentInset = UIEdgeInsetsMake(16, 16, 16, 16+87);
        }
    }
    return _collectionView;
}

@end
