//
//  HZCameraViewController.h
//  RosePDF
//
//  Created by THS on 2024/3/5.
//

#import <UIKit/UIKit.h>

@interface HZCameraViewController : UIViewController

@property (nonatomic, copy) void(^selectFinishBlock)(NSArray <UIImage *>*images);


- (instancetype)initWithInputParams:(NSDictionary *)inputParams;

@end
