//
//  HZPDFConvertingView.m
//  RosePDF
//
//  Created by hzy on 2024-03-02.
//

#import "HZPDFConvertingView.h"
#import "HZCommonHeader.h"
#import <SDWebImage/SDAnimatedImageView+WebCache.h>

@interface HZPDFConvertingView()

@property (nonatomic, strong) SDAnimatedImageView *gifImageView;
@property (nonatomic, strong) UILabel *tipLab;

@end

@implementation HZPDFConvertingView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configView];
    }
    return self;
}

- (void)configView {
    self.backgroundColor = [UIColor whiteColor];
    self.gifImageView = [[SDAnimatedImageView alloc] initWithFrame:CGRectMake((ScreenWidth - 90)/2.0, (ScreenHeight - 90)/2.0, 90, 90)];
    [self addSubview:self.gifImageView];
    
    self.tipLab = [[UILabel alloc] init];
    [self.tipLab setFrame:CGRectMake(0, self.gifImageView.bottom + 20, ScreenWidth, 20)];
    self.tipLab.textAlignment = NSTextAlignmentCenter;
    self.tipLab.font = [UIFont systemFontOfSize:16];
    [self addSubview:self.tipLab];
}

- (void)startConverting {
    // 加载 GIF 图片
    NSURL *gifURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"rose_pdf_loading" ofType:@"gif"]];
    [self.gifImageView sd_setImageWithURL:gifURL completed:nil];
    
    self.tipLab.text = NSLocalizedString(@"str_start_converting", nil);
}

- (void)completeConvertingWithBlock:(void (^)(void))completeBlock {
    NSURL *gifURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"rose_pdf_complete" ofType:@"gif"]];
    [self.gifImageView sd_setImageWithURL:gifURL completed:nil];
    
    NSData *gifData = [NSData dataWithContentsOfURL:gifURL];
    NSTimeInterval duration = [self durationForGifData:gifData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completeBlock();
    });
    
    self.tipLab.text = NSLocalizedString(@"str_complete_converting", nil);
}


- (NSTimeInterval)durationForGifData:(NSData *)data {
    
    //将GIF图片转换成对应的图片源
    CGImageSourceRef gifSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    //获取其中图片源个数，即由多少帧图片组成
    size_t frameCout = CGImageSourceGetCount(gifSource);

    //定义数组存储拆分出来的图片
    NSMutableArray* frames = [[NSMutableArray alloc] init];
    NSTimeInterval totalDuration = 0;
    for (size_t i=0; i<frameCout; i++) {

        //从GIF图片中取出源图片
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);

        //将图片源转换成UIimageView能使用的图片源
        UIImage* imageName = [UIImage imageWithCGImage:imageRef];

        //将图片加入数组中
        [frames addObject:imageName];
        NSTimeInterval duration = [self gifImageDeleyTime:gifSource index:i];
        totalDuration += duration;
        CGImageRelease(imageRef);
    }
    
    //获取循环次数
    NSInteger loopCount;//循环次数
    CFDictionaryRef properties = CGImageSourceCopyProperties(gifSource, NULL);
    if (properties) {
        CFDictionaryRef gif = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
        if (gif) {
            CFTypeRef loop = CFDictionaryGetValue(gif, kCGImagePropertyGIFLoopCount);
            if (loop) {
                //如果loop == NULL，表示不循环播放，当loopCount  == 0时，表示无限循环；
                CFNumberGetValue(loop, kCFNumberNSIntegerType, &loopCount);
            };
        }
    }
    CFRelease(gifSource);
    return totalDuration;
}

//获取GIF图片每帧的时长
- (NSTimeInterval)gifImageDeleyTime:(CGImageSourceRef)imageSource index:(NSInteger)index {
    NSTimeInterval duration = 0;
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, NULL);
    if (imageProperties) {
        CFDictionaryRef gifProperties;
        BOOL result = CFDictionaryGetValueIfPresent(imageProperties, kCGImagePropertyGIFDictionary, (const void **)&gifProperties);
        if (result) {
            const void *durationValue;
            if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFUnclampedDelayTime, &durationValue)) {
                duration = [(__bridge NSNumber *)durationValue doubleValue];
                if (duration < 0) {
                    if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFDelayTime, &durationValue)) {
                        duration = [(__bridge NSNumber *)durationValue doubleValue];
                    }
                }
            }
        }
    }
    
    return duration;
}


@end
