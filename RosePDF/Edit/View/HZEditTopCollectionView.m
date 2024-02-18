//
//  HZEditTopCollectionView.m
//  RosePDF
//
//  Created by THS on 2024/2/6.
//

#import "HZEditTopCollectionView.h"
#import "HZCommonHeader.h"
#import "HZEditTopCell.h"

@interface HZEditTopCollectionView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) HZEditDataboard *databoard;

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation HZEditTopCollectionView
- (instancetype)initWithDataboard:(HZEditDataboard *)databoard {
    if (self = [super init]) {
        self.databoard = databoard;
        [self configView];
    }
    return self;
}
- (void)configView {
    self.backgroundColor = [UIColor yellowColor];
    [self addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HZEditTopCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HZEditTopCell" forIndexPath:indexPath];
    BOOL isAdd = NO;
    if (indexPath.row == 0) {
        isAdd = YES;
    }
    [cell configWithModel:nil isAdd:isAdd];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(56.0, 56.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 16;
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
        [_collectionView registerClass:[HZEditTopCell class] forCellWithReuseIdentifier:@"HZEditTopCell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.contentInset = UIEdgeInsetsMake(16, 16, 16, 16+87);
    }
    return _collectionView;
}

@end
