//
//  HZAsset.m
//  RosePDF
//
//  Created by THS on 2024/2/7.
//

#import "HZAsset.h"

@implementation HZAsset

- (instancetype)initWithAsset:(PHAsset *)asset {
    if (self = [super init]) {
        self.asset = asset;
    }
    return self;
}

- (BOOL)inLocal {
    BOOL local;
    if (self.asset) {
        PHAssetResource *fullSizePhotoResource = nil;
        // 遍历 asset 的 assetResources 数组，查找具有 type 为 PHAssetResourceTypeFullSizePhoto 的资源
        for (PHAssetResource *resource in [PHAssetResource assetResourcesForAsset:self.asset]) {
            if (resource.type == PHAssetResourceTypeFullSizePhoto) {
                fullSizePhotoResource = resource;
                break;
            }
        }
        
        if (fullSizePhotoResource) {
            local = YES;
        } else {
            local = NO;
        }
    } else {
        local = NO;
    }
    return local;
}

- (BOOL)isGif {
    __block BOOL gif = NO;
    NSArray *resourceList = [PHAssetResource assetResourcesForAsset:self.asset];
    [resourceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAssetResource *resource = obj;
        if ([resource.uniformTypeIdentifier isEqualToString:@"com.compuserve.gif"]) {
            gif = YES;
        }
    }];
    return gif;
}

- (void)requestThumbnailWithCompleteBlock:(void (^)(UIImage *))completeBlock {
    // 指定缩略图尺寸
    CGSize targetSize = CGSizeMake(300, 300); // 举例为100x100的尺寸
    // 创建 PHImageManager 对象
    PHImageManager *imageManager = [PHImageManager defaultManager];
    // 请求缩略图
    [imageManager requestImageForAsset:self.asset
                            targetSize:targetSize
                           contentMode:PHImageContentModeAspectFit // 根据需要调整 contentMode
                               options:nil
                         resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        completeBlock(result);
    }];
}

- (void)requestHighQualityWithCompleteBlock:(void (^)(UIImage *))completeBlock {
    // 设置获取图片的参数
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    // 获取图片
    [[PHImageManager defaultManager] requestImageForAsset:self.asset
                                               targetSize:PHImageManagerMaximumSize
                                              contentMode:PHImageContentModeDefault
                                                  options:options
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        NSLog(@"debug--requestHighQuality");
        completeBlock(result);
    }];
    
//    // 设置获取图片数据的参数
//    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
//    options.version = PHImageRequestOptionsVersionOriginal;
//    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
//
//    // 获取图片数据
//    [[PHImageManager defaultManager] requestImageDataForAsset:self.asset
//                                                      options:options
//                                                resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//        NSLog(@"debug--requestHighQuality");
//        UIImage *image = [UIImage imageWithData:imageData];
//        completeBlock(image);
//    }];
}

@end
