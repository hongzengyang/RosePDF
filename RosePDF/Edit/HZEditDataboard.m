//
//  HZEditDataboard.m
//  RosePDF
//
//  Created by THS on 2024/2/6.
//

#import "HZEditDataboard.h"

@implementation HZEditDataboard

- (HZPageModel *)currentPage {
    if (self.currentIndex >= self.project.pageModels.count || self.currentIndex < 0) {
        return nil;
    }
    
    return [self.project.pageModels objectAtIndex:self.currentIndex];
}

@end
