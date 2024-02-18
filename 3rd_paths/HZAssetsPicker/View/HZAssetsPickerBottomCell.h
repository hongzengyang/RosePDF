//
//  HZAssetsPickerBottomCell.h
//  HZAssetsPicker
//
//  Created by THS on 2024/2/18.
//

#import <UIKit/UIKit.h>
#import "HZAsset.h"


@interface HZAssetsPickerBottomCell : UICollectionViewCell

@property (nonatomic, copy) void(^clickDeleteBlock)(HZAsset *asset);


- (void)configWithAsset:(HZAsset *)asset;

@end

