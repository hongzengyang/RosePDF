//
//  HZPDFConvertingView.h
//  RosePDF
//
//  Created by hzy on 2024-03-02.
//

#import <UIKit/UIKit.h>


@interface HZPDFConvertingView : UIView

- (void)startConverting;
- (void)completeConvertingWithBlock:(void(^)(void))completeBlock;

@end

