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
@property (nonatomic, copy) void(^ClickFileBlock)(BOOL selected);
@property (nonatomic, assign) BOOL enableFile;

- (void)addImages:(NSArray *)images;


@end

