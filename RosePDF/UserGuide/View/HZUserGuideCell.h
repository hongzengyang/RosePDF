//
//  HZUserGuideCell.h
//  RosePDF
//
//  Created by THS on 2024/3/21.
//

#import <UIKit/UIKit.h>

@interface HZUserGuideCell : UICollectionViewCell

@property (nonatomic, copy) void(^clickNextBlock)(void);


- (void)configWithImageName:(NSString *)name title:(NSString *)title;

@end
