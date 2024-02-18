//
//  HZAlbumPickerCell.h
//  HZAssetsPicker
//
//  Created by THS on 2024/2/18.
//

#import <UIKit/UIKit.h>
#import "HZAlbum.h"

NS_ASSUME_NONNULL_BEGIN

@interface HZAlbumPickerCell : UICollectionViewCell

- (void)configWithAlbum:(HZAlbum *)album;

@end

NS_ASSUME_NONNULL_END
