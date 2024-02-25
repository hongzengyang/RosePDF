//
//  HZAssetsPickerBottomView.h
//  HZAssetsPicker
//
//  Created by THS on 2024/2/18.
//

#import <UIKit/UIKit.h>
#import "HZAsset.h"
#import "HZAssetsPickerManager.h"

@interface HZAssetsPickerBottomView : UIView

@property (nonatomic, copy) void(^deleteAllBlock)(void);
@property (nonatomic, copy) void(^deleteAeestBlock)(HZAsset *asset);

- (instancetype)initWithFrame:(CGRect)frame databoard:(HZAssetsPickerManager *)databoard;

- (void)reload;

@end
