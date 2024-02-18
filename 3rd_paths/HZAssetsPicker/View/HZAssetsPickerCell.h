//
//  HZAssetsPickerCell.h
//  HZAssetsPicker
//
//  Created by THS on 2024/2/7.
//

#import <UIKit/UIKit.h>
#import "HZAsset.h"

@interface HZAssetsPickerCell : UICollectionViewCell

- (void)configAsset:(HZAsset *)asset;

- (void)configLongPressGesture:(void(^)(void))gestureBlock;

@end

