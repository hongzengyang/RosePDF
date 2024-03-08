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

@property (nonatomic, assign) BOOL isCaptured;
@property (nonatomic, copy) NSString *captureImgPath;
@property (nonatomic, assign) long long captureTime;
@property (nonatomic, copy) NSString *captureTitle;

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) BOOL inLocal;
@property (nonatomic, assign) BOOL isGif;
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, assign) BOOL isCameraEntrance;

- (instancetype)initWithAsset:(PHAsset *)asset;
- (instancetype)initWithImage:(UIImage *)image;

- (long long)createTime;
- (NSString *)title;

- (void)requestThumbnailWithCompleteBlock:(void(^)(UIImage *image))completeBlock;

- (void)requestHighQualityWithCompleteBlock:(void(^)(UIImage *image))completeBlock;

@end

NS_ASSUME_NONNULL_END
