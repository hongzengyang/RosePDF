//
//  HZEditDataboard.m
//  RosePDF
//
//  Created by THS on 2024/2/6.
//

#import "HZEditDataboard.h"

@implementation HZEditDataboard

- (HZPageModel *)currentPage {
    return [self.project.pageModels objectAtIndex:self.currentIndex];
}

@end
