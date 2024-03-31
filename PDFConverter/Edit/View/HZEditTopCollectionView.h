//
//  HZEditTopCollectionView.h
//  RosePDF
//
//  Created by THS on 2024/2/6.
//

#import <UIKit/UIKit.h>
#import "HZEditDataboard.h"

NS_ASSUME_NONNULL_BEGIN

@interface HZEditTopCollectionView : UIView

- (instancetype)initWithDataboard:(HZEditDataboard *)databoard;

- (void)reloadAll;
- (void)reloadCurrent;

@end

NS_ASSUME_NONNULL_END
