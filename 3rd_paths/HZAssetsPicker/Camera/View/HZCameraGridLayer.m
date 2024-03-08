//
//  HZCameraGridLayer.m
//  HZAssetsPicker
//
//  Created by THS on 2024/3/5.
//

#import "HZCameraGridLayer.h"
#import <HZUIKit/HZUIKit.h>

@interface HZCameraGridLayer()

@property (nonatomic, strong) CALayer *hor1;
@property (nonatomic, strong) CALayer *hor2;
@property (nonatomic, strong) CALayer *ver1;
@property (nonatomic, strong) CALayer *ver2;

@end

@implementation HZCameraGridLayer
- (instancetype)init {
    if (self = [super init]) {
        [self configLayer];
    }
    return self;
}

- (void)layoutSublayers {
    [self.hor1 setFrame:CGRectMake(0, self.frame.size.height / 3.0, self.frame.size.width, 1.0)];
    [self.hor2 setFrame:CGRectMake(0, self.frame.size.height / 3.0 * 2.0, self.frame.size.width, 1.0)];
    [self.ver1 setFrame:CGRectMake(self.frame.size.width / 3.0, 0, 1, self.frame.size.height)];
    [self.ver2 setFrame:CGRectMake(self.frame.size.width / 3.0 * 2.0, 0, 1, self.frame.size.height)];
}

- (void)configLayer {
    self.backgroundColor = [UIColor clearColor].CGColor;
    
    CALayer *hor1 = [[CALayer alloc] init];
    [self addSublayer:hor1];
    hor1.backgroundColor = [UIColor hz_getColor:@"FFFFFF" alpha:@"0.3"].CGColor;
    self.hor1 = hor1;
    
    CALayer *hor2 = [[CALayer alloc] init];
    [self addSublayer:hor2];
    hor2.backgroundColor = [UIColor hz_getColor:@"FFFFFF" alpha:@"0.3"].CGColor;
    self.hor2 = hor2;
    
    CALayer *ver1 = [[CALayer alloc] init];
    [self addSublayer:ver1];
    ver1.backgroundColor = [UIColor hz_getColor:@"FFFFFF" alpha:@"0.3"].CGColor;
    self.ver1 = ver1;
    
    CALayer *ver2 = [[CALayer alloc] init];
    [self addSublayer:ver2];
    ver2.backgroundColor = [UIColor hz_getColor:@"FFFFFF" alpha:@"0.3"].CGColor;
    self.ver2 = ver2;
}

@end
