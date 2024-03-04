//
//  HZPageModel.m
//  RosePDF
//
//  Created by THS on 2024/2/4.
//

#import "HZPageModel.h"
#import "HZCommonHeader.h"
#import "HZProjectManager.h"
#import <HZFoundationKit/HZSerializeObject.h>
#import "HZFilterManager.h"

@implementation HZValueModel

HZ_SERIALIZE_CODER_DECODER();
HZ_SERIALIZE_COPY_WITH_ZONE();

@end

@implementation HZFilterModel

HZ_SERIALIZE_CODER_DECODER();
HZ_SERIALIZE_COPY_WITH_ZONE();

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
                @"value" : [HZValueModel class]
             };
}

@end

@implementation HZAdjustModel

HZ_SERIALIZE_CODER_DECODER();
HZ_SERIALIZE_COPY_WITH_ZONE();

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
                @"brightnessValue" : [HZValueModel class],
                @"contrastValue" : [HZValueModel class],
                @"saturationValue" : [HZValueModel class]
             };
}

@end

@interface HZPageModel()

@end

@implementation HZPageModel
HZ_SERIALIZE_CODER_DECODER();
HZ_SERIALIZE_COPY_WITH_ZONE();
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
                @"filter" : [HZFilterModel class],
                @"adjust" : [HZAdjustModel class]
             };
}
- (instancetype)init {
    if (self = [super init]) {
        self.filter = [HZFilterManager defaultFilterModel:(HZFilter_enhance)];
        self.adjust = [HZFilterManager defaultAdjustModel];
    }
    return self;
}

+ (HZPageModel *)readWithPageId:(NSString *)pageId projectId:(NSString *)projectId {
    HZPageModel *pageModel = nil;
    if (pageId.length > 0 && projectId.length > 0) {
        pageModel = [[HZPageModel alloc] init];
        pageModel.identifier = pageId;
        pageModel.projectId = projectId;
        [pageModel readFromDisk];
    }
    return pageModel;
}

- (void)readFromDisk {
    NSString *path = [self configPath];
    NSString *jsonStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    HZPageModel *tmpModel = [HZPageModel yy_modelWithJSON:jsonStr];
    if (tmpModel) {
        self.title = tmpModel.title;
        self.createTime = tmpModel.createTime;
        self.orientation = tmpModel.orientation;
        self.filter = tmpModel.filter;
        self.adjust = tmpModel.adjust;
    }
}

- (void)saveToDisk {
    NSString *path = [self configPath];
    NSString *jsonStr = [self yy_modelToJSONString];
    NSError *error;
    [jsonStr writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

+ (NSString *)folderPathWithPageId:(NSString *)pageId projectId:(NSString *)projectId {
    NSString *pageFolderPath = nil;
    NSString *projectPath = [HZProjectManager projectPathWithIdentifier:projectId];
    if (projectPath.length > 0 && pageId.length > 0) {
        pageFolderPath = [projectPath stringByAppendingPathComponent:pageId];
    }
    return pageFolderPath;
}

- (NSString *)pageFolderPath {
    return [[self class] folderPathWithPageId:self.identifier projectId:self.projectId];
}

- (NSString *)originPath {
    return [[self pageFolderPath] stringByAppendingPathComponent:@"origin.jpg"];
}
- (NSString *)resultPath {
    return [[self pageFolderPath] stringByAppendingPathComponent:@"result.jpg"];
}

- (NSString *)configPath {
    return [[self pageFolderPath] stringByAppendingPathComponent:@"page.config"];
}

- (void)refreshWithCompleteBlock:(void (^)(UIImage *))completeBlock {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *contentImage = [UIImage imageWithContentsOfFile:[self originPath]];
        if (!contentImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(nil);
            });
            return;
        }
        
        //crop
        //rotate
        //filter
        [HZFilterManager makeFilterImageWithImage:contentImage page:self completeBlock:^(UIImage *result ,HZPageModel *page) {
            NSData *resultData = UIImageJPEGRepresentation(result, 0.9);
            BOOL suc = [resultData writeToFile:[self resultPath] atomically:YES];
            
            [self saveToDisk];
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(result);
            });
        }];
    });
}

@end
