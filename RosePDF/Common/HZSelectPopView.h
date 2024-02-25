//
//  HZSelectPopView.h
//  RosePDF
//
//  Created by THS on 2024/2/21.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HZSelectPopType) {
    HZSelectPopType_quality,
    HZSelectPopType_margin,
};


@interface HZSelectPopView : UIView

+ (void)popWithItems:(NSArray <NSString *>*)items
               index:(NSInteger)index
              inView:(UIView *)inView
         relatedView:(UIView *)relatedView
                type:(HZSelectPopType)type
         selectBlock:(void(^)(NSInteger index))selectBlock;

@end
