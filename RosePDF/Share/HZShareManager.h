//
//  HZShareManager.h
//  RosePDF
//
//  Created by THS on 2024/2/28.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HZProjectModel.h"

@interface HZShareManager : NSObject

+ (void)shareWithProject:(HZProjectModel *)project completionWithItemsHandler:(UIActivityViewControllerCompletionWithItemsHandler)completionWithItemsHandler;

@end

