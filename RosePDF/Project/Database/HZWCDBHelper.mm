//
//  HZWCDBHelper.m
//  RosePDF
//
//  Created by THS on 2024/2/6.
//

#import "HZWCDBHelper.h"
#import <WCDB/WCDB.h>
#import "HZProjectManager.h"

#define DataBaseName @"project.db"

static HZWCDBHelper *sharedInstance = nil;
static dispatch_once_t onceToken;

@implementation HZWCDBHelper

//唯一公开实例
+(instancetype)sharedInstance
{
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HZWCDBHelper alloc] init];
    });
    
    if (!sharedInstance)
    {
        [HZWCDBHelper destorySharedInstance];
    }
    
    return sharedInstance;
}

//销毁单例
+(void)destorySharedInstance
{
    onceToken = 0;
    sharedInstance = nil;
}

-(BOOL)createDataBase
{
    BOOL success = NO;
    NSString *localUserCode = @"";
    
    //数据库由/Library/Caches 转换到/Library
    self.dbPath = [self modifyDBPathWithLocalUserCode:localUserCode];
    NSLog(@"ocr dbPath:%@ %@",self.dbPath,[[NSFileManager defaultManager] attributesOfItemAtPath:self.dbPath error:nil]);

    [self createDBQueue];// | SQLITE_OPEN_FILEPROTECTION_NONE];
    
    [[NSFileManager defaultManager] setAttributes:@{NSFileProtectionKey:NSFileProtectionCompleteUntilFirstUserAuthentication} ofItemAtPath:self.dbPath error:nil];
    
    success = YES;
    return success;
}

- (BOOL)startTransaction:(void(^)(void))block {
    [HZWCDBDateBase beginTransaction];
    if (block) {
        block();
    }
    BOOL re = [HZWCDBDateBase commitTransaction];
    if (!re) {
        [HZWCDBDateBase rollbackTransaction];
    }
    return re;
}

#pragma mark -DB LOGIC

- (void)createDBQueue {
    self.dataBase = nil;
    self.dataBase = [[WCTDatabase alloc] initWithPath:self.dbPath];
    [self.dataBase setTokenizer:WCTTokenizerNameWCDB];
}

-(NSString *)modifyDBPathWithLocalUserCode:(NSString *)localUserCode
{
    NSString *newDbPath = nil;
    NSString *ocrFolderPath = [HZProjectManager ocrFolderPath];
    if (ocrFolderPath.length > 0) {
        newDbPath = [ocrFolderPath stringByAppendingPathComponent:DataBaseName];
    }else {
        NSLog(@"- ocrFolderPath is nil -");
    }
    
    return newDbPath;
}

@end

