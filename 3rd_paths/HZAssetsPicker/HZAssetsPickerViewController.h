//
//  HZAssetsPickerViewController.h
//  RosePDF
//
//  Created by THS on 2024/2/7.
//
#import <UIKit/UIKit.h>
#import "UIImage+AssetsPickerParam.h"

@interface HZAssetsPickerViewController : UIViewController


@property (nonatomic, copy) void(^SelectImageBlock)(NSArray <UIImage *>*images);
@property (nonatomic, copy) void(^ClickFileBlock)(void);
@property (nonatomic, assign) BOOL enableFile;


@end

