//
//  HZShareManager.m
//  RosePDF
//
//  Created by THS on 2024/2/28.
//

#import "HZShareManager.h"
#import "HZCommonHeader.h"

@implementation HZShareManager

+ (void)shareWithProject:(HZProjectModel *)project completionWithItemsHandler:(UIActivityViewControllerCompletionWithItemsHandler)completionWithItemsHandler {
    BOOL pdfExist = [project pdfExist];
    if (pdfExist) {
        NSString *pdfPath = [project pdfPath];
        [self shareWithPdfPath:pdfPath completionWithItemsHandler:completionWithItemsHandler];
    }
}

+ (void)shareWithPdfPath:(NSString *)pdfPath completionWithItemsHandler:(UIActivityViewControllerCompletionWithItemsHandler)completionWithItemsHandler {
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
    activityVC.excludedActivityTypes = @[UIActivityTypePostToFacebook,
                                         UIActivityTypePostToTwitter,
                                         UIActivityTypePostToWeibo,
                                         UIActivityTypePrint,
                                         //                                         UIActivityTypeCopyToPasteboard,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeSaveToCameraRoll,
                                         UIActivityTypeAddToReadingList,
                                         UIActivityTypePostToFlickr,
                                         UIActivityTypePostToVimeo,
                                         UIActivityTypePostToTencentWeibo];
    
    if ([[HZSystemManager manager] iPadDevice]) {
        activityVC.popoverPresentationController.sourceView = viewwController.view;
        activityVC.popoverPresentationController.sourceRect = CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight);
        activityVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [viewwController presentViewController:activityVC animated:YES completion:nil];
}

@end
