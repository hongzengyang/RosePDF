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

//保存到数据库
- (BOOL)saveToDataBase;
//在数据库中更新
- (BOOL)updateInDataBase;
//删除在表中的记录
- (BOOL)deleteInDataBase;


@end

NS_ASSUME_NONNULL_END
