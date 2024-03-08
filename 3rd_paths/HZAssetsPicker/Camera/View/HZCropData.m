//
//  HZCropData.m
//  RosePDF
//
//  Created by THS on 2024/3/6.
//

#import "HZCropData.h"

@implementation HZCropData

- (instancetype)initWithPage:(HZPageModel *)page {
    if (self = [super init]) {
        self.pageModel = page;
        self.currentOrientation = page.orientation;
        self.borders = [page.borderArray copy];
    }
    return self;
}

@end
