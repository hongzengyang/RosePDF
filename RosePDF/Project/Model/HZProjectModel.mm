//
//  HZProjectModel.m
//  RosePDF
//
//  Created by THS on 2024/2/4.
//

#import "HZProjectModel.h"
#import <HZFoundationKit/HZSerializeObject.h>
#import "HZWCDBHelper.h"
#import <WCDB/WCDB.h>

#define DB_PROJECT_TABLE_NAME @"db_project_table"


@interface HZProjectModel()<WCTTableCoding>

WCDB_PROPERTY(identifier)
WCDB_PROPERTY(title)
WCDB_PROPERTY(createTime)
WCDB_PROPERTY(updateTime)
WCDB_PROPERTY(pageIds)
WCDB_PROPERTY(folderId)
WCDB_PROPERTY(pdfSize)

@end

@implementation HZProjectModel

HZ_SERIALIZE_CODER_DECODER();
HZ_SERIALIZE_COPY_WITH_ZONE();

#pragma mark - Database
WCDB_IMPLEMENTATION(HZProjectModel)
WCDB_SYNTHESIZE(HZProjectModel, identifier)
WCDB_SYNTHESIZE(HZProjectModel, title)
WCDB_SYNTHESIZE(HZProjectModel, createTime)
WCDB_SYNTHESIZE(HZProjectModel, updateTime)
WCDB_SYNTHESIZE(HZProjectModel, pageIds)
WCDB_SYNTHESIZE(HZProjectModel, folderId)
WCDB_SYNTHESIZE(HZProjectModel, pdfSize)
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
    return [HZWCDBDateBase updateRowsInTable:DB_PROJECT_TABLE_NAME onProperties:{self.class.title,self.class.createTime,self.class.updateTime,self.class.pageIds,self.class.folderId,self.class.pdfSize
    } withObject:self where:self.class.identifier==self.identifier];
}
- (BOOL)deleteInDataBase {
    if ([self.identifier hasPrefix:Tmp_project_prefix]) {
        return YES;
    }
    return [HZWCDBDateBase deleteObjectsFromTable:DB_PROJECT_TABLE_NAME where:self.class.identifier==self.identifier];
}
#pragma mark - Query



@end
