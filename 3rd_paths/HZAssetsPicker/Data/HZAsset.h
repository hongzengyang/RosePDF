//
//  HZAsset.h
//  RosePDF
//
//  Created by THS on 2024/2/7.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface HZAsset : NSObject

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) BOOL inLocal;
@property (nonatomic, assign) BOOL isGif;
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, assign) BOOL isCameraEntrance;

- (instancetype)initWithAsset:(PHAsset *)asset;

- (void)requestThumbnailWithCompleteBlock:(void(^)(UIImage *image))completeBlock;

- (void)requestHighQualityWithCompleteBlock:(void(^)(UIImage *image))completeBlock;

@end

NS_ASSUME_NONNULL_END
