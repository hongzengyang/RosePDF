//
//  HZAlbum.m
//  RosePDF
//
//  Created by THS on 2024/2/7.
//

#import "HZAlbum.h"

@implementation HZAlbum

- (instancetype)initWithCollection:(PHAssetCollection *)assetCollection {
    if (self = [super init]) {
        self.assetCollection = assetCollection;
    }
    return self;
}

- (void)requestAssetsCountWithCompleteBlock:(void (^)(NSInteger))completeBlock {
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:self.assetCollection options:options];
    completeBlock(assets.count);
}

- (void)requestThumbnailImageWithCompleteBlock:(void (^)(UIImage *))completeBlock {
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:self.assetCollection options:options];
    if (assets.count == 0) {
        completeBlock(nil);
        return;
    }
    
    HZAsset *asset = [[HZAsset alloc] initWithAsset:[assets lastObject]];
    [asset requestThumbnailWithCompleteBlock:completeBlock];
}

@end
