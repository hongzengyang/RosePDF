//
//  HZMarginSelectView.m
//  PDFConverter
//
//  Created by hzy on 2024-04-14.
//

#import "HZMarginSelectView.h"
#import "HZCommonHeader.h"
#import "HZProjectDefine.h"

@interface HZMarginSelectView()

@property (nonatomic, strong) UIView *containerView;


@property (nonatomic, strong) UILabel *noneLab;
@property (nonatomic, strong) UILabel *normalLab;
@property (nonatomic, strong) UIImageView *noneImageView;
@property (nonatomic, strong) UIImageView *normalImageView;

@property (nonatomic, weak) UIView *inView;
@property (nonatomic, weak) UIView *relatedView;
@property (nonatomic, copy) void(^SelectBlock)(NSInteger);

@property (nonatomic, assign) NSInteger index;


@end

@implementation HZMarginSelectView

+ (void)popWithMargin:(HZPDFMargin)margin inView:(UIView *)inView relatedView:(UIView *)relatedView selectBlock:(void (^)(NSInteger))selectBlock {
    HZMarginSelectView *popView = [[HZMarginSelectView alloc] initWithMargin:margin inView:inView relatedView:relatedView selectBlock:selectBlock];
    [inView addSubview:popView];
    [popView configView];
}

- (instancetype)initWithMargin:(HZPDFMargin)margin inView:(UIView *)inView relatedView:(UIView *)relatedView selectBlock:(void (^)(NSInteger))selectBlock {
    if (self = [super init]) {
        self.inView = inView;
        self.index = margin;
        self.relatedView = relatedView;
        self.SelectBlock = selectBlock;
    }
    return self;
}

- (void)configView {
    [self setFrame:self.inView.bounds];
    self.backgroundColor = [UIColor clearColor];
    
    @weakify(self);
    [self hz_clickBlock:^{
        @strongify(self);
        [self removeFromSuperview];
    }];
    
    UIView *containerView = [[UIView alloc] init];
    [containerView setSize:CGSizeMake(228, 122)];
    containerView.layer.cornerRadius = 16;
    containerView.layer.masksToBounds = YES;
    
    [self addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.relatedView);
        make.top.equalTo(self.relatedView.mas_bottom);
        make.width.mas_equalTo(containerView.width);
        make.height.mas_equalTo(containerView.height);
    }];
    self.containerView = containerView;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThickMaterialLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [containerView addSubview:blurEffectView];
    [blurEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(containerView);
    }];
    
    {//none
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, containerView.width/2.0, containerView.height)];
        [containerView addSubview:view];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((view.width - 42)/2.0, 14, 42, 51)];
        imageView.backgroundColor = [UIColor redColor];
        [view addSubview:imageView];
        
        UILabel *titleLab = [[UILabel alloc] init];
        [view addSubview:titleLab];
        titleLab.font = [UIFont systemFontOfSize:17];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.textColor = hz_2_textColor;
        titleLab.text = NSLocalizedString(@"str_none", nil);
        [titleLab setFrame:CGRectMake(0, imageView.bottom + 7, view.width, 16)];
        self.noneLab = titleLab;
        
        UIImageView *sImageView = [[UIImageView alloc] initWithFrame:CGRectMake((view.width - 18)/2.0, titleLab.bottom + 4, 18, 18)];
        [view addSubview:sImageView];
        self.noneImageView = sImageView;
        
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [button addTarget:self action:@selector(clickNoneButton) forControlEvents:(UIControlEventTouchUpInside)];
        [view addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(view);
        }];
    }
    
    {//normal
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(containerView.width/2.0, 0, containerView.width/2.0, containerView.height)];
        [containerView addSubview:view];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((view.width - 42)/2.0, 14, 42, 51)];
        imageView.backgroundColor = [UIColor redColor];
        [view addSubview:imageView];
        
        UILabel *titleLab = [[UILabel alloc] init];
        [view addSubview:titleLab];
        titleLab.font = [UIFont systemFontOfSize:17];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.textColor = hz_2_textColor;
        titleLab.text = NSLocalizedString(@"str_normal", nil);
        [titleLab setFrame:CGRectMake(0, imageView.bottom + 7, view.width, 16)];
        self.normalLab = titleLab;
        
        UIImageView *sImageView = [[UIImageView alloc] initWithFrame:CGRectMake((view.width - 18)/2.0, titleLab.bottom + 4, 18, 18)];
        [view addSubview:sImageView];
        self.normalImageView = sImageView;
        
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [button addTarget:self action:@selector(clickNormalButton) forControlEvents:(UIControlEventTouchUpInside)];
        [view addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(view);
        }];
    }
    
    [self updateSelectImageView];
}

- (void)updateSelectImageView {
    if (self.index == HZPDFMargin_normal) {
        self.noneLab.textColor = hz_2_textColor;
        self.normalLab.textColor = hz_main_color;
        self.noneImageView.image = [UIImage imageNamed:@"rose_margin_n"];
        self.normalImageView.image = [UIImage imageNamed:@"rose_margin_s"];
    }else {
        self.noneLab.textColor = hz_main_color;
        self.normalLab.textColor = hz_2_textColor;
        self.noneImageView.image = [UIImage imageNamed:@"rose_margin_s"];
        self.normalImageView.image = [UIImage imageNamed:@"rose_margin_n"];
    }
}

- (void)clickNoneButton {
    [self updateSelectImageView];
    
    if (self.SelectBlock) {
        self.SelectBlock(HZPDFMargin_none);
    }
    
    [self removeFromSuperview];
    
    [[NSUserDefaults standardUserDefaults] setValue:@(HZPDFMargin_none) forKey:pref_key_userSelect_margin];
}

- (void)clickNormalButton {
    [self updateSelectImageView];
    
    if (self.SelectBlock) {
        self.SelectBlock(HZPDFMargin_normal);
    }
    
    [self removeFromSuperview];
    
    [[NSUserDefaults standardUserDefaults] setValue:@(HZPDFMargin_normal) forKey:pref_key_userSelect_margin];
}

@end

