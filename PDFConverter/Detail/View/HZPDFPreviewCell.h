//
//  HZPDFPreviewCell.h
//  RosePDF
//
//  Created by THS on 2024/2/27.
//

#import <UIKit/UIKit.h>
#import "HZPageModel.h"
#import "HZProjectModel.h"

@interface HZPDFPreviewCell : UICollectionViewCell
- (void)configWithModel:(HZPageModel *)page margin:(HZPDFMargin)margin;
@end


