//
//  HZDetailBottomView.h
//  RosePDF
//
//  Created by THS on 2024/2/26.
//

#import <UIKit/UIKit.h>
#import "HZProjectModel.h"

typedef NS_ENUM(NSUInteger, HZDetailBottomItem) {
    HZDetailBottomItemShare,
    HZDetailBottomItemRename,
    HZDetailBottomItemEdit,
    HZDetailBottomItemSetting,
    HZDetailBottomItemDelete
};


@protocol HZDetailBottomViewDelegate <NSObject>

- (void)detailBottomViewClickItem:(HZDetailBottomItem)item;

@end

@interface HZDetailBottomView : UIView

@property (nonatomic, weak) id<HZDetailBottomViewDelegate> delegate;

- (instancetype)initWithProject:(HZProjectModel *)project;


@end


