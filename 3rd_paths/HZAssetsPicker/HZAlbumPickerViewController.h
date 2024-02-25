//
//  HZAlbumPickerViewController.h
//  HZAssetsPicker
//
//  Created by THS on 2024/2/18.
//

#import <UIKit/UIKit.h>
#import "HZAlbum.h"
#import "HZAssetsPickerManager.h"

@interface HZAlbumPickerViewController : UIViewController

@property (nonatomic, copy) void(^SelectAlbum)(HZAlbum *album);

- (instancetype)initWithDataboard:(HZAssetsPickerManager *)databoard;


@end

