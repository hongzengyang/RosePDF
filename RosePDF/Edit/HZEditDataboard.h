//
//  HZEditDataboard.h
//  RosePDF
//
//  Created by THS on 2024/2/6.
//

#import <Foundation/Foundation.h>
#import "HZProjectModel.h"

#define pref_key_click_edit_top  @"pref_key_click_edit_top"
#define pref_key_scroll_preview  @"pref_key_scroll_preview"

@interface HZEditDataboard : NSObject

@property (nonatomic, strong) HZProjectModel *project;

@property (nonatomic, assign) NSInteger currentIndex;

@end
