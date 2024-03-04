//
//  HZProjectModel.m
//  RosePDF
//
//  Created by THS on 2024/2/4.
//

#import "HZProjectModel.h"
#import <HZFoundationKit/HZSerializeObject.h>
#import <HZFoundationKit/NSDate+HZCategory.h>
#import "HZWCDBHelper.h"
#import <WCDB/WCDB.h>
#import "HZProjectManager.h"

#define DB_PROJECT_TABLE_NAME @"db_project_table"

#define pref_key_pdfSize  @"pref_key_pdfSize"


@interface HZProjectModel()<WCTTableCoding>

WCDB_PROPERTY(identifier)
WCDB_PROPERTY(title)
WCDB_PROPERTY(createTime)
WCDB_PROPERTY(updateTime)
WCDB_PROPERTY(pageIds)
WCDB_PROPERTY(folderId)
WCDB_PROPERTY(pdfSize)
WCDB_PROPERTY(margin)
WCDB_PROPERTY(quality)
WCDB_PROPERTY(openPassword)
WCDB_PROPERTY(password)
WCDB_PROPERTY(newFlag)

@end

@implementation HZProjectModel

@synthesize pageModels = _pageModels;

HZ_SERIALIZE_CODER_DECODER();
HZ_SERIALIZE_COPY_WITH_ZONE();

- (instancetype)init {
    if (self = [super init]) {
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
        self.createTime = interval;
        self.updateTime = interval;
        
        self.title = [NSString stringWithFormat:@"%@",[NSDate hz_dateTimeStringWithTime:interval]];
    }
    return self;
}

#pragma mark - Database
WCDB_IMPLEMENTATION(HZProjectModel)
WCDB_SYNTHESIZE(HZProjectModel, identifier)
WCDB_SYNTHESIZE(HZProjectModel, title)
WCDB_SYNTHESIZE(HZProjectModel, createTime)
WCDB_SYNTHESIZE(HZProjectModel, updateTime)
WCDB_SYNTHESIZE(HZProjectModel, pageIds)
WCDB_SYNTHESIZE(HZProjectModel, folderId)
WCDB_SYNTHESIZE(HZProjectModel, pdfSize)
WCDB_SYNTHESIZE(HZProjectModel, margin)
WCDB_SYNTHESIZE(HZProjectModel, quality)
WCDB_SYNTHESIZE(HZProjectModel, openPassword)
WCDB_SYNTHESIZE(HZProjectModel, password)
WCDB_SYNTHESIZE(HZProjectModel, newFlag)
WCDB_PRIMARY(HZProjectModel, identifier)

- (BOOL)saveToDataBase {
    if ([self.identifier hasPrefix:Tmp_project_prefix]) {
        return YES;
    }
    [HZWCDBDateBase createTableAndIndexesOfName:DB_PROJECT_TABLE_NAME withClass:self.class];
    return [HZWCDBDateBase insertOrReplaceObject:self into:DB_PROJECT_TABLE_NAME];
}

- (BOOL)updateInDataBase {
    if ([self.identifier hasPrefix:Tmp_project_prefix]) {
        return YES;
    }
    [HZWCDBDateBase createTableAndIndexesOfName:DB_PROJECT_TABLE_NAME withClass:self.class];
    return [HZWCDBDateBase updateRowsInTable:DB_PROJECT_TABLE_NAME onProperties:{self.class.title,self.class.createTime,self.class.updateTime,self.class.pageIds,self.class.folderId,self.class.pdfSize,self.class.margin,self.class.quality,self.class.openPassword,self.class.password,self.class.newFlag
    } withObject:self where:self.class.identifier==self.identifier];
}
- (BOOL)deleteInDataBase {
    if ([self.identifier hasPrefix:Tmp_project_prefix]) {
        return YES;
    }
    return [HZWCDBDateBase deleteObjectsFromTable:DB_PROJECT_TABLE_NAME where:self.class.identifier==self.identifier];
}
#pragma mark - Query
+ (NSArray<HZProjectModel *> *)queryAllProjects {
    NSArray<HZProjectModel *> *projectList = [HZWCDBDateBase getObjectsOfClass:self fromTable:DB_PROJECT_TABLE_NAME orderBy:self.createTime.order(WCTOrderedDescending)];
    return projectList;
}

#pragma mark - Pdf
- (BOOL)pdfExist {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self pdfPath]];
}

- (NSString *)pdfPath {
    NSString *projectPath = [HZProjectManager projectPathWithIdentifier:self.identifier];
    return [projectPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",self.title]];
}

#pragma mark - User Config
+ (void)golbalConfigPdfSize:(HZPDFSize)size {
    [[NSUserDefaults standardUserDefaults] setValue:@(size) forKey:pref_key_pdfSize];
}

#pragma mark - Setter Getter
- (NSArray<HZPageModel *> *)pageModels {
    if (!_pageModels) {
        if (self.pageIds.length > 0) {
            NSArray *array = [self.pageIds componentsSeparatedByString:@","].copy;
            NSMutableArray *models = [NSMutableArray arrayWithCapacity:array.count];
            NSString *projectId = self.identifier;
            [array enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                HZPageModel *page = [HZPageModel readWithPageId:obj projectId:projectId];
                [models addObject:page];
            }];
            _pageModels = models;
        }
    }
    return _pageModels;
}

- (void)setPageModels:(NSArray<HZPageModel *> *)pageModels {
    _pageModels = pageModels;
    
    NSMutableString *muString = [[NSMutableString alloc] initWithString:@""];
    [pageModels enumerateObjectsUsingBlock:^(HZPageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [muString appendString:obj.identifier];
        if (idx != pageModels.count - 1) {
            [muString appendString:@","];
        }
    }];
    self.pageIds = muString;
}

@end
