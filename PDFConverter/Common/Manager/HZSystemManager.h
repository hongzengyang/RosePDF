//
//  HZSystemManager.h
//  RosePDF
//
//  Created by THS on 2024/3/26.
//

#import <Foundation/Foundation.h>

@interface HZSystemManager : NSObject

@property (nonatomic, assign) BOOL duringFirstOpen;

+ (HZSystemManager *)manager;

- (BOOL)iPadDevice;
- (BOOL)isChina;

@end
