//
//  HZAssetsPickerBottomDeleteAllSheetView.h
//  HZAssetsPicker
//
//  Created by THS on 2024/4/24.
//

#import <UIKit/UIKit.h>


@interface HZAssetsPickerBottomDeleteAllSheetView : UIView

- (instancetype)initWithRelatedView:(UIView *)relatedView clickBlock:(void(^)(void))clickBlock;

@end

