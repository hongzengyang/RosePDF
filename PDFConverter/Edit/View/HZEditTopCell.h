//
//  HZEditTopCell.h
//  RosePDF
//
//  Created by THS on 2024/2/6.
//

#import <UIKit/UIKit.h>
#import "HZPageModel.h"


@interface HZEditTopCell : UICollectionViewCell

- (void)configWithModel:(HZPageModel *)pageModel isAdd:(BOOL)isAdd;

- (void)configSelected:(BOOL)selected;

@end

