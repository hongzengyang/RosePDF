//
//  HZBaseDBHelper.h
//  RosePDF
//
//  Created by THS on 2024/2/6.
//

#import <Foundation/Foundation.h>
@class WCTDatabase;


NS_ASSUME_NONNULL_BEGIN

@interface HZBaseDBHelper : NSObject

@property (nonatomic, strong) WCTDatabase *dataBase;

+(instancetype)new NS_UNAVAILABLE;

//唯一公开实例
+(instancetype)sharedInstance;

//销毁单例
+(void)destorySharedInstance;

-(BOOL)createDataBase;

-(BOOL)renameTable:(NSString *)oldName withName:(NSString *)newName;

@end

NS_ASSUME_NONNULL_END
