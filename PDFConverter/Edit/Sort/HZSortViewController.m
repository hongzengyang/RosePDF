//
//  HZSortViewController.m
//  RosePDF
//
//  Created by THS on 2024/2/21.
//

#import "HZSortViewController.h"
#import "HZCommonHeader.h"
#import "HZBaseNavigationBar.h"
#import "HZSortCell.h"
#import <HZUIKit/HZDragCellCollectionView.h>
#import "HZEditDataboard.h"

@interface HZSortViewController ()<HZDragCollectionViewDataSource,HZDragCellCollectionViewDelegate>

@property (nonatomic, assign) BOOL userSorted;

@property (nonatomic, strong) HZBaseNavigationBar *navBar;

@property (nonatomic, strong) HZDragCellCollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray <HZPageModel *>*data; // 存储数据的数组


@end

@implementation HZSortViewController
- (instancetype)initWithPages:(NSArray<HZPageModel *> *)pages {
    if (self = [super init]) {
        self.data = [[NSMutableArray alloc] initWithArray:pages];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configView];
}

- (void)configView {
    [self.view addSubview:self.navBar];
    self.navBar.backgroundColor = [UIColor clearColor];
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(self.view);
        make.height.mas_equalTo(hz_safeTop + navigationHeight);
    }];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navBar.mas_bottom).offset(30);
        make.leading.equalTo(self.view).offset(16);
        make.trailing.equalTo(self.view).offset(-16);
        make.bottom.equalTo(self.view);
    }];
    
    UILabel *tipLab = [[UILabel alloc] init];
    [self.view addSubview:tipLab];
    tipLab.font = [UIFont systemFontOfSize:12];
    tipLab.textAlignment = NSTextAlignmentCenter;
    tipLab.textColor = [UIColor blackColor];
    tipLab.text = NSLocalizedString(@"str_sort_tip", nil);
    [tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.navBar.mas_bottom);
        make.bottom.equalTo(self.collectionView.mas_top);
    }];
}


#pragma mark - Collection View
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.data.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HZSortCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HZSortCell" forIndexPath:indexPath];
    
    [cell configWithPage:[self.data objectAtIndex:indexPath.row]];
    
    return cell;
}

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.width, 100);
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - Drag Delegate
-(BOOL)dragCellCollectionViewShouldBeginExchange:(HZDragCellCollectionView *)dragCellCollectionView sourceIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    return (sourceIndexPath.section == destinationIndexPath.section);
}

-(void)dragCellCollectionView:(HZDragCellCollectionView *)dragCellCollectionView updateSourceWithSourceIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSLog(@"- pages : %@ %@ -",sourceIndexPath,destinationIndexPath);

    @weakify(self);
    [self safeDataSourceHandler:^{
        @strongify(self);
        id obj = [self.data objectAtIndex:sourceIndexPath.row];
        [self.data removeObjectAtIndex:sourceIndexPath.row];
        [self.data insertObject:obj atIndex:destinationIndexPath.row];
        self.userSorted = YES;
    }];
}

-(void)safeDataSourceHandler:(void(^)(void))handler {
    @synchronized (self) {
        if (handler) {
            handler();
        }
    }
}


#pragma mark -lazy
-(HZDragCellCollectionView *)collectionView {
    if (!_collectionView)
    {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsZero;
        layout.minimumLineSpacing = 16;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[HZDragCellCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.dragZoomScale = 1.1;
        _collectionView.dragCellAlpha = 1.0;
        _collectionView.canDrag = YES;
        _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
        [_collectionView registerClass:[HZSortCell class] forCellWithReuseIdentifier:@"HZSortCell"];
    }
    return _collectionView;
}

- (HZBaseNavigationBar *)navBar {
    if (!_navBar) {
        _navBar = [[HZBaseNavigationBar alloc] init];
        [_navBar configBackImage:[UIImage imageNamed:@"rose_back"]];
        [_navBar configTitle:NSLocalizedString(@"str_reorder", nil)];
        [_navBar configRightTitle:NSLocalizedString(@"str_done", nil)];
        
        @weakify(self);
        _navBar.clickBackBlock = ^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        };
        _navBar.clickRightBlock = ^{
            @strongify(self);
            if (self.userSorted) {
                [[NSNotificationCenter defaultCenter] postNotificationName:pref_key_sort_finish object:[self.data copy]];
            }
            [self.navigationController popViewControllerAnimated:YES];
        };
    }
    return _navBar;
}

@end
