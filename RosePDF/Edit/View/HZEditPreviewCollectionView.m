//
//  HZEditPreviewCollectionView.m
//  RosePDF
//
//  Created by THS on 2024/2/6.
//

#import "HZEditPreviewCollectionView.h"
#import "HZCommonHeader.h"

@interface HZEditPreviewCollectionView()

@property (nonatomic, strong) HZEditDataboard *databoard;

@end

@implementation HZEditPreviewCollectionView
- (instancetype)initWithDataboard:(HZEditDataboard *)databoard {
    if (self = [super init]) {
        self.databoard = databoard;
        [self configView];
    }
    return self;
}
- (void)configView {
    self.backgroundColor = [UIColor greenColor];
}

@end
