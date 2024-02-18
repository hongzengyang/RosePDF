//
//  HZEditTopCell.h
//  RosePDF
//
//  Created by THS on 2024/2/6.
//

#import <UIKit/UIKit.h>
#import "HZPageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HZEditTopCell : UICollectionViewCell

- (void)configWithModel:(HZPageModel *)pageModel isAdd:(BOOL)isAdd;

@end

NS_ASSUME_NONNULL_END
