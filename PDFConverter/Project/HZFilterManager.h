//
//  HZFilterManager.h
//  RosePDF
//
//  Created by THS on 2024/2/29.
//

#import <Foundation/Foundation.h>
#import "HZProjectDefine.h"
#import <UIKit/UIKit.h>
@class HZFilterModel;
@class HZAdjustModel;
@class HZPageModel;

@interface HZFilterManager : NSObject

+ (NSString *)filterNameWithType:(HZFilterType)type;
+ (HZFilterModel *)defaultFilterModel:(HZFilterType)type;
+ (HZAdjustModel *)defaultAdjustModel;

+ (void)makeFilterImageWithImage:(UIImage *)image page:(HZPageModel *)pageModel completeBlock:(void(^)(UIImage *result, HZPageModel *page))completeBlock;

@end

