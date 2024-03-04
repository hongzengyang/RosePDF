//
//  HZHomeNavigationBar.h
//  RosePDF
//
//  Created by THS on 2024/2/5.
//

#import <UIKit/UIKit.h>
#import "HZCommonHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface HZHomeNavigationBar : UIView

- (void)configSelectMode:(BOOL)isSelectMode;
- (void)configSwipeUpMode:(BOOL)isSwipeUpMode;

@end

NS_ASSUME_NONNULL_END
