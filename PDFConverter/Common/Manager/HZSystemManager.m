//
//  HZSystemManager.m
//  RosePDF
//
//  Created by THS on 2024/3/26.
//

#import "HZSystemManager.h"
@import UIKit;

@implementation HZSystemManager
+ (HZSystemManager *)manager {
    static dispatch_once_t pred;
    static HZSystemManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[HZSystemManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        id value = [[NSUserDefaults standardUserDefaults] valueForKey:@"pref_key_during_first_open"];
        if (!value) {
            self.duringFirstOpen = YES;
        }else {
            self.duringFirstOpen = NO;
        }
        [[NSUserDefaults standardUserDefaults] setValue:@"NO" forKey:@"pref_key_during_first_open"];
    }
    return self;
}

- (BOOL)iPadDevice {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return YES;
    }else {
        return NO;
    }
}

@end
