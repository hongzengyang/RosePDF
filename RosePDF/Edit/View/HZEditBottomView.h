//
//  HZEditBottomView.h
//  RosePDF
//
//  Created by THS on 2024/2/6.
//

#import <UIKit/UIKit.h>
#import "HZEditDataboard.h"

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

- (instancetype)initWithDataboard:(HZEditDataboard *)databoard;

@end

NS_ASSUME_NONNULL_END
