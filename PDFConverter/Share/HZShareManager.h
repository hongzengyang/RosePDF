//
//  HZShareManager.h
//  RosePDF
//
//  Created by THS on 2024/2/28.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HZProjectModel.h"

@interface HZShareParam : NSObject
@property (nonatomic, strong) HZProjectModel *project;
@property (nonatomic, strong) UIView *relatedView;
@property (nonatomic, assign) UIPopoverArrowDirection arrowDirection;
@end

@interface HZShareManager : NSObject

+ (void)shareWithParam:(HZShareParam *)param
completionWithItemsHandler:(UIActivityViewControllerCompletionWithItemsHandler)completionWithItemsHandler;

@end

