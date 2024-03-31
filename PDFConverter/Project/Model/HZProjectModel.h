//
//  HZProjectModel.h
//  RosePDF
//
//  Created by THS on 2024/2/4.
//

#import "HZBaseModel.h"
#import "HZPageModel.h"
#import "HZProjectDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface HZProjectModel : HZBaseModel

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) long long createTime;
@property (nonatomic, assign) long long updateTime;
@property (nonatomic, strong) NSString *pageIds;
@property (nonatomic, copy) NSString *folderId;
@property (nonatomic, assign) HZPDFSize pdfSize;
@property (nonatomic, assign) HZPDFOrientation pdfOrientation;
@property (nonatomic, assign) HZPDFMargin margin;
@property (nonatomic, assign) HZPDFQuality quality;
@property (nonatomic, assign) BOOL openPassword;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign) BOOL newFlag;

@property (nonatomic, strong) NSArray <HZPageModel *>*pageModels;

+ (NSArray <HZProjectModel *>*)queryAllProjects;
+ (NSArray <HZProjectModel *>*)searchWithText:(NSString *)text;
//保存到数据库
- (BOOL)saveToDataBase;
//在数据库中更新
- (BOOL)updateInDataBase;
//删除在表中的记录
- (BOOL)deleteInDataBase;

- (BOOL)pdfExist;
- (NSString *)pdfPath;


+ (void)golbalConfigPdfSize:(HZPDFSize)size;

@end

NS_ASSUME_NONNULL_END

