//
//  HZAssetsPickerManager.m
//  RosePDF
//
//  Created by THS on 2024/2/7.
//

#import "HZAssetsPickerManager.h"
#import <Photos/Photos.h>
#import "UIImage+AssetsPickerParam.h"

#define pref_key_lastSelectAlnumIdentifier  @"pref_key_lastSelectAlnumIdentifier"

@interface HZAssetsPickerManager()

@property (nonatomic, strong, readwrite) NSMutableArray <HZAsset *>*selectedAssets;

@property (nonatomic, strong, readwrite) NSArray <HZAsset *>*assetsList;
@property (nonatomic, strong, readwrite) NSArray <HZAlbum *>*albumsList;
@property (nonatomic, strong, readwrite) HZAlbum *currentAlbum;

@property (nonatomic, strong) NSLock *lock;
@end

@implementation HZAssetsPickerManager

//+ (HZAssetsPickerManager *)manager {
//    static dispatch_once_t pred;
//    static HZAssetsPickerManager *sharedInstance = nil;
//    dispatch_once(&pred, ^{
//        sharedInstance = [[HZAssetsPickerManager alloc] init];
//    });
//    return sharedInstance;
//}

- (instancetype)init {
    if (self = [super init]) {
        self.selectedAssets = [[NSMutableArray alloc] init];
        self.lock = [[NSLock alloc] init];
    }
    return self;
}

- (void)clean {
    [self.selectedAssets removeAllObjects];
    self.assetsList = nil;
    self.currentAlbum = nil;
}

+ (void)requestAuthorizationWithCompleteBlock:(HZAssetsPickCompleteBlock)completeBlock {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL complete;
            switch (status) {
                case PHAuthorizationStatusAuthorized:
                    // 用户已授权，可以访问相册或照片库数据
                    complete = YES;
                    break;
                case PHAuthorizationStatusDenied:
                case PHAuthorizationStatusRestricted:
                    // 用户已拒绝或受限制，无法访问相册或照片库数据
                    complete = NO;
                    break;
                case PHAuthorizationStatusNotDetermined:
                    // 用户尚未做出选择，可以继续请求授权
                    // 在此添加相关操作代码
                    break;
                case PHAuthorizationStatusLimited:
                    // 权限限制的
                    complete = YES;
                default:
                    break;
            }
            completeBlock(complete);
        });
    }];
}

- (void)requestCurrentAlbumWithCompleteBlock:(HZAssetsPickCompleteBlock)completeBlock {
    if (self.currentAlbum.assets.count > 0) {
        [self.lock lock];
        self.assetsList = [self.currentAlbum.assets copy];
        [self.lock unlock];
        if (completeBlock) {
            completeBlock(YES);
        }
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
        
        PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:self.currentAlbum.assetCollection options:options];
        
        NSMutableArray <HZAsset *>*muArray = [[NSMutableArray alloc] init];
        
        [assets enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            HZAsset *hzAsset = [[HZAsset alloc] initWithAsset:obj];
            [muArray addObject:hzAsset];
        }];
        
        {
            HZAsset *camera = [[HZAsset alloc] initWithAsset:nil];
            camera.isCameraEntrance = YES;
            [muArray insertObject:camera atIndex:0];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.lock lock];
            self.assetsList = [muArray copy];
            [self.lock unlock];
            self.currentAlbum.assets = [muArray copy];
            
            if (completeBlock) {
                completeBlock(YES);
            }
        });
    });
}

- (BOOL)isSelected:(HZAsset *)asset {
//    __block BOOL select = NO;
//    [self.selectedAssets enumerateObjectsUsingBlock:^(HZAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([obj.asset.localIdentifier isEqualToString:asset.asset.localIdentifier]) {
//            select = YES;
//        }
//    }];
//    return select;
    return [self.selectedAssets containsObject:asset];
}

- (void)addAsset:(HZAsset *)asset {
    [self.lock lock];
    [self.selectedAssets addObject:asset];
    [self.lock unlock];
    
    [self.selectedAssets enumerateObjectsUsingBlock:^(HZAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.index = idx + 1;
    }];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [asset requestHighQualityWithCompleteBlock:^(UIImage * _Nonnull image) {
                    
        }];
    });
}

- (void)deleteAsset:(HZAsset *)asset {
    [self.lock lock];
    if ([self.selectedAssets containsObject:asset]) {
        [self.selectedAssets removeObject:asset];
        asset.index = 0;
    }
    [self.lock unlock];
    
    [self.selectedAssets enumerateObjectsUsingBlock:^(HZAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.index = idx + 1;
    }];
}

- (void)deleAllAssets {
    [self.selectedAssets enumerateObjectsUsingBlock:^(HZAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.index = 0;
    }];
    
    [self.lock lock];
    [self.selectedAssets removeAllObjects];
    [self.lock unlock];
}

- (void)selectAlbum:(HZAlbum *)album {
    self.currentAlbum = album;
    [[NSUserDefaults standardUserDefaults] setValue:@(album.assetCollection.assetCollectionSubtype) forKey:pref_key_lastSelectAlnumIdentifier];
}

- (void)requestHighQualityImagesWithCompleteBlock:(void (^)(NSArray<UIImage *> *))completeBlock {
    
    __block void(^copyCompleteBlock)(NSArray<UIImage *> *) = completeBlock;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block NSInteger callbackCount = 0;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        NSMutableArray *muArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.selectedAssets.count; i++) {
            CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();
            NSLog(@"debug--开始第%d条任务,startTime:%lf",i,startTime);
            HZAsset *asset = self.selectedAssets[i];
            [asset requestHighQualityWithCompleteBlock:^(UIImage * _Nonnull image) {
                dispatch_semaphore_signal(semaphore);
                CFTimeInterval endTime = CFAbsoluteTimeGetCurrent();
                if (image) {
                    NSLog(@"debug--已完成第%d条任务,成功,endTime:%lf",i,(endTime - startTime));
                }else {
                    NSLog(@"debug--已完成第%d条任务,失败,endTime:%lf",i,(endTime - startTime));
                }
                callbackCount++;
                if (image) {
                    [muArray addObject:image];
                    image.createTime = [asset.asset.creationDate timeIntervalSince1970];
                    image.title = [asset.asset valueForKey:@"filename"];
                }
                if (callbackCount == self.selectedAssets.count) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (copyCompleteBlock) {
                            copyCompleteBlock([muArray copy]);
                            copyCompleteBlock = nil;
                        }
                    });
                }
            }];
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
    });
}

#pragma mark - Lazy
- (HZAlbum *)currentAlbum {
    if (!_currentAlbum) {
        // 获取所有智能相册
        PHFetchResult<PHAssetCollection *> *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                                                       subtype:PHAssetCollectionSubtypeAny
                                                                                                       options:nil];
        NSMutableArray<PHAssetCollection *> *allAlbums = [NSMutableArray array];
        [allAlbums addObjectsFromArray:[smartAlbums objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, smartAlbums.count)]]];
        // 遍历所有相册
        HZAlbum *userLibraryCollection;
        HZAlbum *lastSelectCollection;
        PHAssetCollectionSubtype subType;
        PHAssetCollectionSubtype lastSelect = [[[NSUserDefaults standardUserDefaults] valueForKey:pref_key_lastSelectAlnumIdentifier] integerValue];
        
        NSMutableArray *muArray = [[NSMutableArray alloc] init];
        for (PHAssetCollection *album in allAlbums) {
            HZAlbum *hzAlbum = [[HZAlbum alloc] initWithCollection:album];
            [muArray addObject:hzAlbum];
            
            if (album.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                userLibraryCollection = hzAlbum;
            }
            if (album.assetCollectionSubtype == lastSelect) {
                lastSelectCollection = hzAlbum;
            }
        }
        self.albumsList = [muArray copy];
        
        if (lastSelectCollection) {
            _currentAlbum = lastSelectCollection;
        }else if (userLibraryCollection) {
            _currentAlbum = userLibraryCollection;
        }
    }
    return _currentAlbum;
}

@end
