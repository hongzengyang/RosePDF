//
//  HZHomeMenuView.h
//  RosePDF
//
//  Created by THS on 2024/3/8.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HZHomeMenuType) {
    HZHomeMenuType_select,
    HZHomeMenuType_setting,
};

@interface HZHomeMenuView : UIView

+ (void)popInView:(UIView *)inView
      relatedView:(UIView *)relatedView
      selectBlock:(void(^)(HZHomeMenuType index))selectBlock;

@end

