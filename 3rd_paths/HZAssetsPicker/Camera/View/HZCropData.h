//
//  HZCropData.h
//  RosePDF
//
//  Created by THS on 2024/3/6.
//

#import <Foundation/Foundation.h>
#import "HZPageModel.h"

@interface HZCropData : NSObject

@property (nonatomic, assign) BOOL modified;

@property (nonatomic, strong) HZPageModel *pageModel;
@property (nonatomic, assign) HZPageOrientation currentOrientation;
@property (nonatomic, strong) NSArray <NSValue *>*borders; 

@property (nonatomic, assign) CGSize horizontalSize; // image left right ->size
@property (nonatomic, assign) CGSize verticalSize;   // image up   down  ->size

@property (nonatomic, assign) CGAffineTransform transform;

- (instancetype)initWithPage:(HZPageModel *)page;

@end

