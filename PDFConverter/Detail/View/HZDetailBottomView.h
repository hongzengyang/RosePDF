//
//  HZDetailBottomView.h
//  RosePDF
//
//  Created by THS on 2024/2/26.
//

#import <UIKit/UIKit.h>
#import "HZProjectModel.h"

@class HZVerticalButton;

typedef NS_ENUM(NSUInteger, HZDetailBottomItem) {
    HZDetailBottomItemRename,
    HZDetailBottomItemEdit,
    HZDetailBottomItemSetting,
    HZDetailBottomItemShare,
    HZDetailBottomItemDelete
};


@protocol HZDetailBottomViewDelegate <NSObject>

- (void)detailBottomViewClickItem:(HZDetailBottomItem)item;

@end

@interface HZDetailBottomView : UIView

@property (nonatomic, strong) HZVerticalButton *shareBtn;
@property (nonatomic, strong) HZVerticalButton *deleteBtn;

@property (nonatomic, weak) id<HZDetailBottomViewDelegate> delegate;

- (instancetype)initWithProject:(HZProjectModel *)project;


@end


