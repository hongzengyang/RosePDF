//
//  HZEditBottomView.h
//  RosePDF
//
//  Created by THS on 2024/2/6.
//

#import <UIKit/UIKit.h>
#import "HZEditDataboard.h"

@class HZVerticalButton;

typedef NS_ENUM(NSUInteger, HZEditBottomItem) {
    HZEditBottomItemFilter,
    HZEditBottomItemLeft,
    HZEditBottomItemRight,
    HZEditBottomItemCrop,
    HZEditBottomItemReorder,
    HZEditBottomItemDelete
};

NS_ASSUME_NONNULL_BEGIN

@protocol HZEditBottomViewDelegate <NSObject>

- (void)editBottomViewClickItem:(HZEditBottomItem)item;

@end

@interface HZEditBottomView : UIView

@property (nonatomic, weak) id<HZEditBottomViewDelegate> delegate;

@property (nonatomic, strong) HZVerticalButton *deleteBtn;

- (instancetype)initWithDataboard:(HZEditDataboard *)databoard;

- (void)checkDeleteEnable;

@end

NS_ASSUME_NONNULL_END
