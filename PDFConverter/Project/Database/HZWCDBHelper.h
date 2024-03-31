//
//  HZWCDBHelper.h
//  RosePDF
//
//  Created by THS on 2024/2/6.
//

#import "HZBaseDBHelper.h"
#import "HZBaseDBHelper.h"

#define HZWCDBDateBase [HZWCDBHelper sharedInstance].dataBase

NS_ASSUME_NONNULL_BEGIN

@interface HZWCDBHelper : HZBaseDBHelper

@property (nonatomic, copy) NSString *dbPath;

- (BOOL)startTransaction:(void(^)(void))block;

@end

NS_ASSUME_NONNULL_END
