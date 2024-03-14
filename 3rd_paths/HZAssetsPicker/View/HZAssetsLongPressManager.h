//
//  HZAssetsLongPressManager.h
//  HZAssetsPicker
//
//  Created by THS on 2024/3/12.
//

#import <Foundation/Foundation.h>
#import "HZAsset.h"
@import UIKit;
@import Photos;

@interface HZAssetsLongPressManager : NSObject

+ (HZAssetsLongPressManager *)manager;

- (void)showFromCell:(UIImageView *)imageView asset:(HZAsset *)asset;
- (void)dismiss;

@end

