//
//  HZBaseDBHelper.m
//  RosePDF
//
//  Created by THS on 2024/2/6.
//

#import "HZBaseDBHelper.h"
#import <WCDB/WCDB.h>

@interface HZBaseDBHelper()

@end

static HZBaseDBHelper *sharedInstance = nil;
static dispatch_once_t onceToken;

@implementation HZBaseDBHelper

//唯一公开实例
+(instancetype)sharedInstance
{
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HZBaseDBHelper alloc] init];
    });

    if (!sharedInstance)
    {
        [HZBaseDBHelper destorySharedInstance];
    }

    return sharedInstance;
}

//销毁单例
+(void)destorySharedInstance
{
    onceToken = 0;
    sharedInstance = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        BOOL suc = [self createDataBase];
        if (!suc)
        {
            return nil;
        }
    }
    return self;
}

-(BOOL)createDataBase
{
    return NO;
}

-(BOOL)renameTable:(NSString *)oldName withName:(NSString *)newName
{
    return [_dataBase exec:(WCDB::StatementAlterTable().alter(oldName.UTF8String).rename(newName.UTF8String))];
}

- (WCTDatabase *)dataBase
{
#ifdef DEBUG
    if ([[NSThread currentThread] isMainThread])
    {
//        NSLog(@"isMainThread");
    }
#endif
    return _dataBase;
}

@end

