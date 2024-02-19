//
//  HZPageModel.h
//  RosePDF
//
//  Created by THS on 2024/2/4.
//

#import "HZBaseModel.h"

typedef NS_ENUM(NSUInteger, HZPageOrientation) {
    HZPageOrientation_up,
    HZPageOrientation_left,
    HZPageOrientation_down,
    HZPageOrientation_right
};

@interface HZPageModel : HZBaseModel

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *projectId;
@property (nonatomic, assign) HZPageOrientation orientation;


+ (HZPageModel *)readWithPageId:(NSString *)pageId projectId:(NSString *)projectId;

+ (NSString *)folderPathWithPageId:(NSString *)pageId projectId:(NSString *)projectId;
- (NSString *)originPath;
- (NSString *)resultPath;

- (void)refreshWithCompleteBlock:(void(^)(void))completeBlock;

@end

