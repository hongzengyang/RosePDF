//
//  HZEditDataboard.h
//  RosePDF
//
//  Created by THS on 2024/2/6.
//

#import <Foundation/Foundation.h>
#import "HZProjectModel.h"

#define pref_key_click_edit_top       @"pref_key_click_edit_top"
#define pref_key_scroll_preview       @"pref_key_scroll_preview"
#define pref_key_add_assets_finished  @"pref_key_add_assets_finished"
#define pref_key_sort_finish          @"pref_key_sort_finish"

@interface HZEditDataboard : NSObject

@property (nonatomic, strong) HZProjectModel *project;
@property (nonatomic, strong) HZProjectModel *originProject;

@property (nonatomic, assign) NSInteger currentIndex;

@end
