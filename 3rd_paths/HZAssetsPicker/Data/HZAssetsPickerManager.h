//
//  HZAssetsPickerManager.h
//  RosePDF
//
//  Created by THS on 2024/2/7.
//

#import <Foundation/Foundation.h>
#import "HZAsset.h"
#import "HZAlbum.h"

typedef void(^HZAssetsPickCompleteBlock)(BOOL complete);

//#define HZAssetsManager    [HZAssetsPickerManager manager]

@interface HZAssetsPickerManager : NSObject

@property (nonatomic, strong, readonly) NSMutableArray <HZAsset *>*selectedAssets;
@property (nonatomic, strong, readonly) NSArray <HZAsset *>*assetsList;
@property (nonatomic, strong, readonly) NSArray <HZAlbum *>*albumsList;
@property (nonatomic, strong, readonly) HZAlbum *currentAlbum;

//+ (HZAssetsPickerManager *)manager;

- (void)clean;

+ (void)requestAuthorizationWithCompleteBlock:(HZAssetsPickCompleteBlock)completeBlock;

- (void)requestCurrentAlbumWithCompleteBlock:(HZAssetsPickCompleteBlock)completeBlock;

- (BOOL)isSelected:(HZAsset *)asset;
- (void)addAsset:(HZAsset *)asset;
- (void)deleteAsset:(HZAsset *)asset;
- (void)deleAllAssets;

- (void)selectAlbum:(HZAlbum *)album;

- (void)requestHighQualityImagesWithCompleteBlock:(void(^)(NSArray <UIImage *>*))completeBlock;

@end
