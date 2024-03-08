//
//  HZHomeNavigationBar.h
//  RosePDF
//
//  Created by THS on 2024/2/5.
//

#import <UIKit/UIKit.h>
#import "HZCommonHeader.h"

@protocol HZHomeNavigationBarDelegate <NSObject>

- (void)clickMultiSelectButton;
- (void)clickAppSettingsButton;

- (void)clickSelectAllButton;
- (void)clickCancelSelectAllButton;
- (void)clickSelectFinishButton;

@end


@interface HZHomeNavigationBar : UIView

@property (nonatomic, weak) id <HZHomeNavigationBarDelegate> delegate;


- (void)configSelectMode:(BOOL)isSelectMode;
- (void)configSwipeUpMode:(BOOL)isSwipeUpMode;

@end
