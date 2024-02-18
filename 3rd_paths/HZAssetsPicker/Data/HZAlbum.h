//
//  HZAlbum.h
//  RosePDF
//
//  Created by THS on 2024/2/7.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "HZAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface HZAlbum : NSObject

@property (nonatomic, strong) PHAssetCollection *assetCollection;

@property (nonatomic, strong) NSArray <HZAsset *>*assets;

- (instancetype)initWithCollection:(PHAssetCollection *)assetCollection;

- (void)requestAssetsCountWithCompleteBlock:(void(^)(NSInteger count))completeBlock;
- (void)requestThumbnailImageWithCompleteBlock:(void(^)(UIImage *image))completeBlock;

@end

NS_ASSUME_NONNULL_END
