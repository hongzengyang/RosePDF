//
//  HZHomeCell.h
//  RosePDF
//
//  Created by THS on 2024/2/23.
//

#import <UIKit/UIKit.h>
#import "HZProjectModel.h"

@interface HZHomeCell : UITableViewCell

@property (nonatomic, copy) void(^clickMoreBlock)(void);
@property (nonatomic, copy) void(^clickShareBlock)(void);

- (void)configWithProject:(HZProjectModel *)project isSelectMode:(BOOL)isSelectMode isSelect:(BOOL)isSelect;

@end
