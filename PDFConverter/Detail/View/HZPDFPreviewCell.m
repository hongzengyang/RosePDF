//
//  HZPDFPreviewCell.m
//  RosePDF
//
//  Created by THS on 2024/2/27.
//

#import "HZPDFPreviewCell.h"
#import "HZCommonHeader.h"

@interface HZPDFPreviewCell()

@property (nonatomic, strong) UIImageView *previewImageView;

@end

@implementation HZPDFPreviewCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configView];
    }
    return self;
}

- (void)configView {
    self.backgroundColor = [UIColor whiteColor];
    self.previewImageView = [[UIImageView alloc] init];
    self.previewImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.previewImageView];
}

- (void)configWithModel:(HZPageModel *)page margin:(HZPDFMargin)margin {
    UIImage *resultImage = [UIImage imageWithContentsOfFile:[page resultPath]];
    self.previewImageView.image = resultImage;
    
    CGFloat width;
    CGFloat height;
    switch (margin) {
        case HZPDFMargin_normal:{
            width = self.width * 0.8;
            height = self.height * 0.8;
        }
            break;
        default:{
            width = self.width;
            height = self.height;
        }
            break;
    }
    [self.previewImageView setFrame:CGRectMake((self.width - width)/2.0, (self.height - height)/2.0, width, height)];
}

@end
