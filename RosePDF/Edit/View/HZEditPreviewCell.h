//
//  HZEditPreviewCell.h
//  RosePDF
//
//  Created by THS on 2024/2/19.
//

#import <UIKit/UIKit.h>
#import "HZPageModel.h"

@interface HZEditPreviewCell : UICollectionViewCell

- (void)configWithModel:(HZPageModel *)pageModel filterMode:(BOOL)filterMode;

- (void)resetZoom;

@end

