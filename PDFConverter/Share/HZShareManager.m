//
//  HZShareManager.m
//  RosePDF
//
//  Created by THS on 2024/2/28.
//

#import "HZShareManager.h"
#import "HZCommonHeader.h"

@implementation HZShareParam

@end

@implementation HZShareManager

+ (void)shareWithParam:(HZShareParam *)param
completionWithItemsHandler:(UIActivityViewControllerCompletionWithItemsHandler)completionWithItemsHandler {
    BOOL pdfExist = [param.project pdfExist];
    if (!pdfExist) {
        return;
    }
    NSString *pdfPath = [param.project pdfPath];
    if (pdfPath.length == 0) {
        return;
    }
    
    UIViewController *viewwController = [UIView hz_viewController];
    if (!viewwController) {
        return;
    }
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:pdfPath]] applicationActivities:nil];
    if (completionWithItemsHandler) {
        [activityVC setCompletionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
            completionWithItemsHandler(activityType,completed,returnedItems,activityError);
        }];
    }
    //不出现在活动项目
    activityVC.excludedActivityTypes = @[UIActivityTypePostToWeibo,
                                         UIActivityTypePrint,
                                         //                                         UIActivityTypeCopyToPasteboard,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeSaveToCameraRoll,
                                         UIActivityTypePostToFlickr,
                                         UIActivityTypePostToVimeo,
                                         UIActivityTypePostToTencentWeibo];
    
    if ([[HZSystemManager manager] iPadDevice]) {
        if (!param.relatedView) {
            activityVC.popoverPresentationController.sourceView = viewwController.view;
            activityVC.popoverPresentationController.sourceRect = CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight);
            activityVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }else {
            activityVC.popoverPresentationController.sourceView = param.relatedView;
            activityVC.popoverPresentationController.permittedArrowDirections = param.arrowDirection;
            switch (param.arrowDirection) {
                case UIPopoverArrowDirectionUp:
                    activityVC.popoverPresentationController.sourceRect = CGRectMake(param.relatedView.width/2.0, 0, 0, 0);
                    break;
                case UIPopoverArrowDirectionLeft:
                    activityVC.popoverPresentationController.sourceRect = CGRectMake(param.relatedView.width, param.relatedView.height/2.0, 0, 0);
                    break;
                case UIPopoverArrowDirectionRight:
                    activityVC.popoverPresentationController.sourceRect = CGRectMake(0, param.relatedView.height/2.0, 0, 0);
                    break;
                default:
                    activityVC.popoverPresentationController.sourceRect = CGRectMake(param.relatedView.width/2.0, 0, 0, 0);
                    break;
            }
        }
    }
    [viewwController presentViewController:activityVC animated:YES completion:nil];
}

@end
