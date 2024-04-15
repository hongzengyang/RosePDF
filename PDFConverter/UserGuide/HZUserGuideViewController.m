//
//  HZUserGuideViewController.m
//  RosePDF
//
//  Created by THS on 2024/3/21.
//

#import "HZUserGuideViewController.h"
#import "HZCommonHeader.h"
#import "HZUserGuideCell.h"

#define pref_key_userGuide_displayed  @"pref_key_userGuide_displayed"

@interface HZUserGuideViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray <NSString *>*imageList;
@property (nonatomic, strong) NSArray <NSString *>*titleList;
@end

@implementation HZUserGuideViewController

+ (BOOL)checkDisplayed {
    return NO;
    id value = [[NSUserDefaults standardUserDefaults] valueForKey:pref_key_userGuide_displayed];
    if (value) {
        return YES;
    }else {
        return NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[HZSystemManager manager] iPadDevice]) {
        self.imageList = @[@"welcome_1_iPad",@"welcome_2_iPad",@"welcome_3_iPad",@"welcome_4_iPad"];
    }else {
        self.imageList = @[@"welcome_1_iPhone",@"welcome_2_iPhone",@"welcome_3_iPhone",@"welcome_4_iPhone"];
    }
    self.titleList = @[[NSString stringWithFormat:NSLocalizedString(@"str_guide_title1", nil),NSLocalizedString(@"str_appname", nil)],NSLocalizedString(@"str_guide_title2", nil),NSLocalizedString(@"str_guide_title3", nil),NSLocalizedString(@"str_guide_title4", nil)];
    [self configView];
}

- (void)configView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.scrollEnabled = NO;
    [self.collectionView registerClass:[HZUserGuideCell class] forCellWithReuseIdentifier:@"HZUserGuideCell"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.automaticallyAdjustsScrollIndicatorInsets = NO;
    self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageList.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HZUserGuideCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HZUserGuideCell" forIndexPath:indexPath];
    [cell configWithImageName:self.imageList[indexPath.row] title:self.titleList[indexPath.row]];
    
    @weakify(self);
    [cell setClickNextBlock:^{
        @strongify(self);
        if (indexPath.row == self.imageList.count - 1) {
            if (self.overBlock) {
                self.overBlock();
            }
            [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:pref_key_userGuide_displayed];
        }else {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section] atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:YES];
        }
    }];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(ScreenWidth, ScreenHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.01;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.01;
}

@end
