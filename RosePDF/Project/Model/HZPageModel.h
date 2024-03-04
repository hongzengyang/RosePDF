//
//  HZPageModel.h
//  RosePDF
//
//  Created by THS on 2024/2/4.
//

#import "HZBaseModel.h"
#import <UIKit/UIKit.h>
#import "HZProjectDefine.h"

@interface HZValueModel : NSObject
@property (nonatomic, assign) CGFloat intensity;
@property (nonatomic, assign) CGFloat min;
@property (nonatomic, assign) CGFloat max;
@property (nonatomic, assign) CGFloat defaultValue;
@end

@interface HZFilterModel : NSObject

@property (nonatomic, assign) HZFilterType filterType;
@property (nonatomic, strong) HZValueModel *value;

@end

@interface HZAdjustModel : NSObject

@property (nonatomic, strong) HZValueModel *brightnessValue;//亮度
@property (nonatomic, strong) HZValueModel *contrastValue;  //对比度   (0-4,1)  (1-3,1.5)
@property (nonatomic, strong) HZValueModel *saturationValue;//饱和度

@end

@interface HZPageModel : HZBaseModel

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *projectId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) long long createTime;
@property (nonatomic, assign) HZPageOrientation orientation;
@property (nonatomic, strong) HZFilterModel *filter;
@property (nonatomic, strong) HZAdjustModel *adjust;

+ (HZPageModel *)readWithPageId:(NSString *)pageId projectId:(NSString *)projectId;

- (void)saveToDisk;

+ (NSString *)folderPathWithPageId:(NSString *)pageId projectId:(NSString *)projectId;
- (NSString *)originPath;
- (NSString *)resultPath;

- (void)refreshWithCompleteBlock:(void(^)(UIImage *result))completeBlock;

@end

