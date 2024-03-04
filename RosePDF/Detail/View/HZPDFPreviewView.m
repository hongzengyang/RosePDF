//
//  HZPDFPreviewView.m
//  RosePDF
//
//  Created by THS on 2024/2/27.
//

#import "HZPDFPreviewView.h"
#import "HZCommonHeader.h"
#import "HZPDFPreviewCell.h"
#import "HZPDFMaker.h"

@interface HZPDFPreviewView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) HZProjectModel *project;

@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation HZPDFPreviewView

- (instancetype)initWithProject:(HZProjectModel *)project {
    if (self = [super init]) {
        self.project = project;
        [self configView];
    }
    return self;
}

- (void)configView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[HZPDFPreviewCell class] forCellWithReuseIdentifier:@"HZPDFPreviewCell"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)updateWithProject:(HZProjectModel *)project {
    self.project = project;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.project.pageModels.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HZPDFPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HZPDFPreviewCell" forIndexPath:indexPath];
    HZPageModel *pageModel = [self.project.pageModels objectAtIndex:indexPath.row];
    [cell configWithModel:pageModel margin:self.project.margin];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width = collectionView.width;
    CGFloat height;
    switch (self.project.pdfSize) {
        case HZPDFSize_autoFit:{
            HZPageModel *pageModel = [self.project.pageModels objectAtIndex:indexPath.row];
            UIImage *resultImage = [UIImage imageWithContentsOfFile:[pageModel resultPath]];
            height = width * (resultImage.size.height / resultImage.size.width);
        }
            break;
        default: {
            CGSize size = [HZPDFMaker pageSizeWithoutOrigin:self.project.pdfSize];
            height = width * (size.height / size.width);
        }
            break;
    }
    
    return CGSizeMake(width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
