//
//  HZCurrentAlbumView.h
//  HZAssetsPicker
//
//  Created by THS on 2024/2/7.
//

#import <UIKit/UIKit.h>
#import "HZAlbum.h"

NS_ASSUME_NONNULL_BEGIN

@interface HZCurrentAlbumView : UIView

@property (nonatomic, copy) void(^ClickBlock)(void);


- (void)updateWithAlbum:(HZAlbum *)album;

@end

NS_ASSUME_NONNULL_END
