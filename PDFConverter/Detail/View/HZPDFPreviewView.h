//
//  HZPDFPreviewView.h
//  RosePDF
//
//  Created by THS on 2024/2/27.
//

#import <UIKit/UIKit.h>
#import "HZProjectModel.h"


@interface HZPDFPreviewView : UIView

- (instancetype)initWithProject:(HZProjectModel *)project;
- (void)updateWithProject:(HZProjectModel *)project;

@end


