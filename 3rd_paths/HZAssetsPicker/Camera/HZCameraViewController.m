//
//  HZCameraViewController.m
//  RosePDF
//
//  Created by THS on 2024/3/5.
//

#import "HZCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "UIImage+AssetsPickerParam.h"
#import "HZCameraUtils.h"
#import <HZUIKit/HZUIKit.h>
#import <HZFoundationKit/HZFoundationKit.h>
#import <Masonry/Masonry.h>
#import "HZCameraGridLayer.h"
#import "HZCameraPreviewView.h"
#import "HZCameraButton.h"

@interface HZCameraViewController ()<AVCapturePhotoCaptureDelegate>
@property (nonatomic, strong) NSArray <UIImage *>*inputImages;
@property (nonatomic, strong) NSMutableArray <UIImage *>*capturedImages;

// ------------- 设备配置等 -------------
//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property(nonatomic)AVCaptureDevice *device;
//AVCaptureDeviceInput 代表输入设备，使用AVCaptureDevice 来初始化
@property(nonatomic)AVCaptureDeviceInput *input;
//照片输出流
@property (nonatomic)AVCapturePhotoOutput *imageOutPut;
//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property(nonatomic)AVCaptureSession *session;
//图像预览层，实时显示捕获的图像
@property(nonatomic)AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *flashBtn;
@property (nonatomic, strong) UIButton *gridBtn;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) HZCameraPreviewView *previewView;
@property (nonatomic, strong) HZCameraButton *cameraBtn;

@property (nonatomic, strong) UIView *captureView;
@property (nonatomic, strong) HZCameraGridLayer *gridLayer;

@property (nonatomic, strong)UIView *backBlackView;//拍照时的蒙层动画
@end

@implementation HZCameraViewController
- (instancetype)initWithInputParams:(NSDictionary *)inputParams {
    if (self = [super init]) {
        self.inputImages = [inputParams valueForKey:@"images"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    @weakify(self);
    [HZCameraUtils checkCameraPermissionWithViewController:self completeBlock:^(BOOL complete) {
        @strongify(self);
        [self configView];
        [self configCamera];
    }];
}

- (void)configView {
    [self.view addSubview:self.topView];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.captureView];
    [self.captureView.layer addSublayer:self.gridLayer];
    {//点击拍照闪现蒙层
        self.backBlackView = [[UIView alloc] init];
        self.backBlackView.frame = self.captureView.bounds;
        self.backBlackView.backgroundColor = [UIColor blackColor];
        self.backBlackView.alpha = 0;
        [self.captureView addSubview:self.backBlackView];
    }
}

- (void)configCamera {
    // 1.1 初始化session会话，用来结合输入输出
    self.session = [[AVCaptureSession alloc] init];
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset3840x2160]) {
        [self.session setSessionPreset:AVCaptureSessionPreset3840x2160];  //拿到的图像的大小可以自行设定
    }
    
    // 1.2 获取视频输入设备(摄像头)
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 1.3 创建视频输入源 并添加到会话
    self.input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    
    // 1.4 创建视频输出源 并添加到会话
    self.imageOutPut = [[AVCapturePhotoOutput alloc]init];
    if ([self.session canAddOutput:self.imageOutPut]) {
        [self.session addOutput:self.imageOutPut];
    }
    AVCaptureConnection *imageConnection = [self.imageOutPut connectionWithMediaType:AVMediaTypeVideo];
    // 设置 imageConnection 控制相机拍摄图片的角度方向
    if (imageConnection.supportsVideoOrientation) {
        imageConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    
    // 2.1 使用self.session初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = self.captureView.bounds;
    self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait; // 图层展示拍摄角度方向
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.captureView.layer insertSublayer:self.previewLayer atIndex:0];
    
    // 3.1 属性配置
    if ([self.device lockForConfiguration:nil]) { // 修改设备的属性，先加锁
        //闪光灯自动
        if ([[self.imageOutPut supportedFlashModes] containsObject:@(AVCaptureFlashModeAuto)]) {
            self.imageOutPut.photoSettingsForSceneMonitoring.flashMode = AVCaptureFlashModeAuto;
        }
        //自动白平衡
        if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [self.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        //解锁
        [self.device unlockForConfiguration];
    }
    
    // 4.1开始采集画面
    [self.session startRunning];
}

- (void)updatePreviewImage {
    UIImage *image;
    if (self.capturedImages.count > 0) {
        image = [self.capturedImages lastObject];
    }else if (self.inputImages.count > 0) {
        image = [self.inputImages lastObject];
    }
    [self.previewView updateWithImage:image count:self.inputImages.count + self.capturedImages.count];
}

- (void)handleClickPreview {
    if (self.selectFinishBlock) {
        self.selectFinishBlock([self.capturedImages copy]);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Click
- (void)clickBackButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clickGridButton:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        button.tintColor = [UIColor hz_getColor:@"262626"];
    }else {
        button.tintColor = [UIColor hz_getColor:@"888888"];
    }
    self.gridLayer.hidden = !self.gridBtn.selected;
}

- (void)clickFlashButton:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        button.tintColor = [UIColor hz_getColor:@"262626"];
    }else {
        button.tintColor = [UIColor hz_getColor:@"888888"];
    }
}

- (void)clickCameraButton {
    AVCaptureConnection * videoConnection = [self.imageOutPut connectionWithMediaType:AVMediaTypeVideo];
    if (videoConnection ==  nil) {
        return;
    }
    
    [UIView animateWithDuration:0.06 animations:^{
        self.backBlackView.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.backBlackView.alpha = 0;
        }];
        
    }];
    AVCapturePhotoSettings *set = [AVCapturePhotoSettings photoSettings];
    if (self.flashBtn.selected) {
        set.flashMode = AVCaptureFlashModeOn;
    }else {
        set.flashMode = AVCaptureFlashModeOff;
    }
    [self.imageOutPut capturePhotoWithSettings:set delegate:self];
}

#pragma mark - AVCapturePhotoCaptureDelegate
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error {
    if (!error) {
        NSData *imageData = [photo fileDataRepresentation];
        UIImage *image = [UIImage imageWithData:imageData];
//        CGImageRef ref1 = image.CGImage;
        image = [self fixOrientation:image];
//        CGImageRef ref2 = image.CGImage;
        [self.capturedImages addObject:image];
        [self updatePreviewImage];
        
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
        image.createTime = interval;
        image.title = [NSString stringWithFormat:@"Cam_%@.JPG",[NSDate hz_dateTimeString1WithTime:interval]];
    }
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
    UIImage *img;
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
    transform = CGAffineTransformRotate(transform, -M_PI_2);
    CGContextRef ctx =CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,CGImageGetBitsPerComponent(aImage.CGImage),0,CGImageGetColorSpace(aImage.CGImage),CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    CGContextDrawImage(ctx,CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
    CGImageRef cgimg =CGBitmapContextCreateImage(ctx);
    img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    return img;
}


#pragma mark - Lazy
- (UIView *)topView {
    if (!_topView) {
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, [UIView hz_safeTop] + 44)];
        topView.backgroundColor = [UIColor whiteColor];
        _topView = topView;
        
        UIButton *back = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [topView addSubview:back];
        [back setImage:[UIImage imageNamed:@"rose_close"] forState:(UIControlStateNormal)];
        [back addTarget:self action:@selector(clickBackButton) forControlEvents:(UIControlEventTouchUpInside)];
        [back mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(28);
            make.leading.equalTo(topView).offset(16);
            make.top.equalTo(topView).offset([UIView hz_safeTop] + 8);
        }];
        
        UIButton *grid = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [topView addSubview:grid];
        UIImage *girdImage = [[UIImage imageNamed:@"rose_camera_grid"] imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];
        [grid setImage:girdImage forState:(UIControlStateNormal)];
        [grid setImage:girdImage forState:(UIControlStateSelected)];
        grid.tintColor = [UIColor hz_getColor:@"888888"];
        [grid addTarget:self action:@selector(clickGridButton:) forControlEvents:(UIControlEventTouchUpInside)];
        [grid mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(28);
            make.trailing.equalTo(topView).offset(-16);
            make.top.equalTo(topView).offset([UIView hz_safeTop] + 8);
        }];
        self.gridBtn = grid;
        
        UIButton *flash = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [topView addSubview:flash];
        UIImage *flashImage = [[UIImage imageNamed:@"rose_camera_flash"] imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];
        [flash setImage:flashImage forState:(UIControlStateNormal)];
        [flash setImage:flashImage forState:(UIControlStateSelected)];
        flash.tintColor = [UIColor hz_getColor:@"888888"];
        [flash addTarget:self action:@selector(clickFlashButton:) forControlEvents:(UIControlEventTouchUpInside)];
        [flash mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(28);
            make.trailing.equalTo(grid.mas_leading).offset(-8);
            make.top.equalTo(topView).offset([UIView hz_safeTop] + 8);
        }];
        self.flashBtn = flash;
    }
    return _topView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        CGFloat height = [UIView hz_safeBottom] + 112;
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - height, self.view.width, height)];
        bottomView.backgroundColor = [UIColor hz_getColor:@"ffffff" alpha:@"0.8"];
        
        self.previewView = [[HZCameraPreviewView alloc] init];
        [bottomView addSubview:self.previewView];
        [self.previewView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(bottomView).offset(16);
            make.top.equalTo(bottomView).offset(22);
            make.width.height.mas_equalTo(64);
        }];
        [bottomView setNeedsLayout];
        [bottomView layoutIfNeeded];
        @weakify(self);
        [self.previewView hz_clickBlock:^{
            @strongify(self);
            [self handleClickPreview];
        }];
        
        [self updatePreviewImage];
        
        self.cameraBtn = [[HZCameraButton alloc] initCustomWithFrame:CGRectMake((bottomView.width - 78)/2.0, 17, 78, 78)];
        [bottomView addSubview:self.cameraBtn];
        [self.cameraBtn addTarget:self action:@selector(clickCameraButton) forControlEvents:(UIControlEventTouchUpInside)];
        
        _bottomView = bottomView;
    }
    return _bottomView;
}

- (UIView *)captureView {
    if (!_captureView) {
        _captureView = [[UIView alloc] initWithFrame:CGRectMake(0, self.topView.bottom, self.view.width, self.bottomView.top - self.topView.bottom)];
        _captureView.backgroundColor = [UIColor whiteColor];
    }
    return _captureView;
}

- (HZCameraGridLayer *)gridLayer {
    if (!_gridLayer) {
        _gridLayer = [[HZCameraGridLayer alloc] init];
        [_gridLayer setFrame:self.captureView.bounds];
        _gridLayer.hidden = !self.gridBtn.selected;
    }
    return _gridLayer;
}

- (NSMutableArray<UIImage *> *)capturedImages {
    if (!_capturedImages) {
        _capturedImages = [[NSMutableArray alloc] init];
    }
    return _capturedImages;
}

@end
