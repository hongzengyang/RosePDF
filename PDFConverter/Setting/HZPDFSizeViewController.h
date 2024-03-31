//
//  HZPDFSizeViewController.h
//  RosePDF
//
//  Created by THS on 2024/2/20.
//

#import "HZBaseViewController.h"
#import "HZProjectModel.h"

@interface HZPDFSizeViewController : HZBaseViewController

@property (nonatomic, copy) void(^SelectPdfSizeBlock)(HZPDFSize size,HZPDFOrientation orientation);

- (instancetype)initWithInputPDFSize:(HZPDFSize)pdfSize orientation:(HZPDFOrientation)orientation;

@end


