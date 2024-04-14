//
//  HZMarginSelectView.h
//  PDFConverter
//
//  Created by hzy on 2024-04-14.
//

#import <UIKit/UIKit.h>
#import "HZProjectDefine.h"

@interface HZMarginSelectView : UIView

+ (void)popWithMargin:(HZPDFMargin)margin inView:(UIView *)inView relatedView:(UIView *)relatedView selectBlock:(void (^)(NSInteger))selectBlock;

@end


