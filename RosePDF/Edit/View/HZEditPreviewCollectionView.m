//
//  HZEditPreviewCollectionView.m
//  RosePDF
//
//  Created by THS on 2024/2/6.
//

#import "HZEditPreviewCollectionView.h"
#import "HZCommonHeader.h"
#import "HZEditPreviewCell.h"

@interface HZEditPreviewCollectionView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) HZEditDataboard *databoard;

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation HZEditPreviewCollectionView
- (instancetype)initWithDataboard:(HZEditDataboard *)databoard {
    if (self = [super init]) {
        self.databoard = databoard;
        [self configView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleIndexChanged) name:pref_key_click_edit_top object:nil];
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

- (void)reloadView {
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.databoard.project.pageModels.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HZEditPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HZEditPreviewCell" forIndexPath:indexPath];
    HZPageModel *pageModel = [self.databoard.project.pageModels objectAtIndex:indexPath.row];
    [cell configWithModel:pageModel filterMode:self.databoard.isFilterMode];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.frame.size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger page = roundf(scrollView.contentOffset.x/scrollView.bounds.size.width);
    if (self.databoard.currentIndex != page) {
        [[self currentCell] resetZoom];
        self.databoard.currentIndex = page;
        [[NSNotificationCenter defaultCenter] postNotificationName:pref_key_scroll_preview object:nil];
    }
}

#pragma mark - Notification
- (void)handleIndexChanged {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.databoard.currentIndex inSection:0] atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:NO];
}

#pragma mark - Private
- (HZEditPreviewCell *)currentCell {
    HZEditPreviewCell *cell;
    if (self.databoard.currentIndex >= self.databoard.project.pageModels.count) {
        return nil;
    }
    cell = (HZEditPreviewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.databoard.currentIndex inSection:0]];
    return cell;
}

#pragma mark - Lazy
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[HZEditPreviewCell class] forCellWithReuseIdentifier:@"HZEditPreviewCell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}


@end
