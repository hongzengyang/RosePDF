//
//  HZIAPDetainmentView.h
//  PDFConverter
//
//  Created by THS on 2024/4/24.
//

#import <UIKit/UIKit.h>



@interface HZIAPDetainmentView : UIView

- (instancetype)initWithFrame:(CGRect)frame closeBlock:(void(^)(void))closeBlock buySuccessBlock:(void(^)(void))buySuccessBlock;

@end

