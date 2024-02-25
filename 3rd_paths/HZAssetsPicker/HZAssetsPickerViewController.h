//
//  HZAssetsPickerViewController.h
//  RosePDF
//
//  Created by THS on 2024/2/7.
//
#import <UIKit/UIKit.h>
#import "UIImage+AssetsPickerParam.h"

NS_ASSUME_NONNULL_BEGIN

@interface HZAssetsPickerViewController : UIViewController

@property (nonatomic, copy) void(^SelectImageBlock)(NSArray <UIImage *>*images);


@end

NS_ASSUME_NONNULL_END
