//
//  HZAssetsTypeView.m
//  HZAssetsPicker
//
//  Created by hzy on 2024-05-01.
//

#import "HZAssetsTypeView.h"
#import <HZUIKit/HZUIKit.h>
#import <HZFoundationKit/HZFoundationKit.h>
#import <Masonry/Masonry.h>

typedef NS_ENUM(NSUInteger, HZEntranceType) {
    HZEntranceType_photo,
    HZEntranceType_camera,
    HZEntranceType_file,
};

@interface HZAssetsTypeView()

@property (nonatomic, assign) HZEntranceType type;

@property (nonatomic, strong) UIView *photoView;
@property (nonatomic, strong) UIImageView *photoIconImageView;
@property (nonatomic, strong) UILabel *photoLab;

@property (nonatomic, strong) UIView *cameraView;
@property (nonatomic, strong) UIImageView *cameraIconImageView;
@property (nonatomic, strong) UILabel *cameraLab;

@property (nonatomic, strong) UIView *fileView;
@property (nonatomic, strong) UIImageView *fileIconImageView;
@property (nonatomic, strong) UILabel *fileLab;

@property (nonatomic, assign) BOOL enableFile;

@end

@implementation HZAssetsTypeView
- (instancetype)initWithFrame:(CGRect)frame enableFile:(BOOL)enableFile {
    if (self = [super initWithFrame:frame]) {
        self.enableFile = enableFile;
        [self configView];
    }
    return self;
}

- (void)configView {
    CGFloat led = 16;
    CGFloat space = 20;
    CGFloat width = (self.width - led - led - space - space)/3.0;
    if (self.enableFile) {
        self.photoView = [[UIView alloc] init];
        [self addSubview:self.photoView];
        [self.photoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(led);
            make.top.equalTo(self).offset(16);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(64);
        }];
        
        self.cameraView = [[UIView alloc] init];
        [self addSubview:self.cameraView];
        [self.cameraView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(16);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(64);
        }];
        
        self.fileView = [[UIView alloc] init];
        [self addSubview:self.fileView];
        [self.fileView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self).offset(-16);
            make.top.equalTo(self).offset(16);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(64);
        }];
    }else {
        self.photoView = [[UIView alloc] init];
        [self addSubview:self.photoView];
        [self.photoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.mas_centerX).offset(-(space/2.0));
            make.top.equalTo(self).offset(16);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(64);
        }];
        
        self.cameraView = [[UIView alloc] init];
        [self addSubview:self.cameraView];
        [self.cameraView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.mas_centerX).offset(space/2.0);
            make.top.equalTo(self).offset(16);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(64);
        }];
    }
    
    UIButton *btn1 = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.photoView addSubview:btn1];
    [btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.photoView);
    }];
    [btn1 addTarget:self action:@selector(clickPhoto) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIButton *btn2 = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.cameraView addSubview:btn2];
    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.cameraView);
    }];
    [btn2 addTarget:self action:@selector(clickCamera) forControlEvents:(UIControlEventTouchUpInside)];
    if (self.enableFile) {
        UIButton *btn3 = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [self.fileView addSubview:btn3];
        [btn3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.fileView);
        }];
        [btn3 addTarget:self action:@selector(clickFile) forControlEvents:(UIControlEventTouchUpInside)];
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    self.photoView.layer.cornerRadius = 10;
    self.photoView.layer.masksToBounds = YES;
    self.cameraView.layer.cornerRadius = 10;
    self.cameraView.layer.masksToBounds = YES;
    self.fileView.layer.cornerRadius = 10;
    self.fileView.layer.masksToBounds = YES;
    
    self.photoIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.photoView.width - 34)/2.0, 10, 34, 30)];
    self.photoIconImageView.image = [[UIImage imageNamed:@"rose_asset_photo"] imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];
    [self.photoView addSubview:self.photoIconImageView];
    self.photoLab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.photoIconImageView.bottom, self.photoView.width, 15)];
    [self.photoView addSubview:self.photoLab];
    self.photoLab.textAlignment = NSTextAlignmentCenter;
    self.photoLab.font = [UIFont systemFontOfSize:12 weight:(UIFontWeightBold)];
    self.photoLab.text = NSLocalizedString(@"str_photo", nil);
    
    self.cameraIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.cameraView.width - 34)/2.0, 10, 34, 30)];
    self.cameraIconImageView.image = [[UIImage imageNamed:@"rose_asset_camera"] imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];
    [self.cameraView addSubview:self.cameraIconImageView];
    self.cameraLab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.cameraIconImageView.bottom, self.cameraView.width, 15)];
    [self.cameraView addSubview:self.cameraLab];
    self.cameraLab.textAlignment = NSTextAlignmentCenter;
    self.cameraLab.font = [UIFont systemFontOfSize:12 weight:(UIFontWeightBold)];
    self.cameraLab.text = NSLocalizedString(@"str_camera", nil);
    
    if (self.enableFile) {
        self.fileIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.fileView.width - 34)/2.0, 10, 34, 30)];
        self.fileIconImageView.image = [[UIImage imageNamed:@"rose_asset_file"] imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];
        [self.fileView addSubview:self.fileIconImageView];
        self.fileLab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.fileIconImageView.bottom, self.fileView.width, 15)];
        [self.fileView addSubview:self.fileLab];
        self.fileLab.textAlignment = NSTextAlignmentCenter;
        self.fileLab.font = [UIFont systemFontOfSize:12 weight:(UIFontWeightBold)];
        self.fileLab.text = NSLocalizedString(@"str_file", nil);
    }
    
    self.photoView.backgroundColor = [UIColor hz_getColor:@"FFFFFF" alpha:@"0.3"];
    self.photoView.layer.borderColor = [UIColor hz_getColor:@"2B96FA"].CGColor;
    self.photoView.layer.borderWidth = 1;
    self.photoIconImageView.tintColor = [UIColor hz_getColor:@"2B96FA"];
    self.photoLab.textColor = [UIColor hz_getColor:@"2B96FA"];
    
    self.cameraView.backgroundColor = [UIColor hz_getColor:@"E4E3EB"];
    self.cameraView.layer.borderWidth = 0;
    self.cameraIconImageView.tintColor = [UIColor hz_getColor:@"000000"];
    self.cameraLab.textColor = [UIColor hz_getColor:@"000000"];
    
    self.fileView.backgroundColor = [UIColor hz_getColor:@"E4E3EB"];
    self.fileView.layer.borderWidth = 0;
    self.fileIconImageView.tintColor = [UIColor hz_getColor:@"000000"];
    self.fileLab.textColor = [UIColor hz_getColor:@"000000"];
    
    {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [self.photoView insertSubview:blurEffectView atIndex:0];
        [blurEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.photoView);
        }];
    }
    {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [self.cameraView insertSubview:blurEffectView atIndex:0];
        [blurEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.cameraView);
        }];
    }
    
    if (self.enableFile) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [self.fileView insertSubview:blurEffectView atIndex:0];
        [blurEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.fileView);
        }];
    }
}

- (void)clickPhoto {
    self.type = HZEntranceType_photo;
    if (self.delegate && [self.delegate respondsToSelector:@selector(assetsTypeViewDidClickPhoto)]) {
        [self.delegate assetsTypeViewDidClickPhoto];
    }
}

- (void)clickCamera {
    self.type = HZEntranceType_camera;
    if (self.delegate && [self.delegate respondsToSelector:@selector(assetsTypeViewDidClickCamera)]) {
        [self.delegate assetsTypeViewDidClickCamera];
    }
}

- (void)clickFile {
    self.type = HZEntranceType_file;
    if (self.delegate && [self.delegate respondsToSelector:@selector(assetsTypeViewDidClickFile)]) {
        [self.delegate assetsTypeViewDidClickFile];
    }
}

@end
