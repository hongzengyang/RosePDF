//
//  HZHomeMenuView.m
//  RosePDF
//
//  Created by THS on 2024/3/8.
//

#import "HZHomeMenuView.h"
#import "HZCommonHeader.h"

@interface HZHomeMenuView()

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) NSMutableArray <UIButton *>*buttons;
@property (nonatomic, strong) NSMutableArray <UILabel *>*labels;

@property (nonatomic, strong) NSArray<NSString *> *items;
@property (nonatomic, weak) UIView *inView;
@property (nonatomic, weak) UIView *relatedView;
@property (nonatomic, assign) HZHomeMenuType type;
@property (nonatomic, copy) void(^SelectBlock)(HZHomeMenuType);


@property (nonatomic, assign) CGFloat itemHeight;

@end

@implementation HZHomeMenuView

+ (void)popInView:(UIView *)inView relatedView:(UIView *)relatedView selectBlock:(void (^)(HZHomeMenuType))selectBlock {
    HZHomeMenuView *popView = [[HZHomeMenuView alloc] initInView:inView relatedView:relatedView selectBlock:selectBlock];
    [inView addSubview:popView];
    [popView configView];
}

- (instancetype)initInView:(UIView *)inView relatedView:(UIView *)relatedView selectBlock:(void (^)(HZHomeMenuType))selectBlock {
    if (self = [super init]) {
        self.inView = inView;
        self.relatedView = relatedView;
        self.SelectBlock = selectBlock;
        self.itemHeight = 44;
        self.buttons = [[NSMutableArray alloc] init];
        self.labels = [[NSMutableArray alloc] init];
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
    [containerView setSize:CGSizeMake(228, self.itemHeight * 2)];
    containerView.layer.cornerRadius = 16;
    containerView.layer.masksToBounds = YES;
    
    [self addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.relatedView).offset(-16);
        make.top.equalTo(self.relatedView.mas_bottom).offset(8);
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
    
    
    self.items = @[NSLocalizedString(@"str_select", nil),NSLocalizedString(@"str_settings", nil)];
    NSArray <NSString *>*images = @[@"rose_home_select",@"rose_setting"];
    [self.items enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *itemView = [self createItemViewWithItem:obj imageName:images[idx] addSeparater:(idx != self.items.count -1) width:self.width];
        [containerView addSubview:itemView];
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(containerView);
            make.height.mas_equalTo(self.itemHeight);
            make.top.mas_equalTo(idx * self.itemHeight);
        }];
    }];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
//    {//shadow
//        UIView *shadow = [[UIView alloc] init];
//        [self insertSubview:shadow belowSubview:containerView];
//        [shadow setFrame:CGRectInset(containerView.frame, 16, 0)];
//        shadow.layer.shadowColor = hz_getColorWithAlpha(@"000000", 0.2).CGColor;
//        shadow.layer.shadowOffset = CGSizeMake(20, -3);
//        shadow.layer.shadowRadius = 10;
//        shadow.layer.shadowOpacity = 0.5;
//        shadow.backgroundColor = [UIColor whiteColor];
//    }
}


- (UIView *)createItemViewWithItem:(NSString *)item imageName:(NSString *)imageName addSeparater:(BOOL)addSeparater width:(CGFloat)width {
    UIView *view = [[UIView alloc] init];
    view.size = CGSizeMake(width, self.itemHeight);
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [view addSubview:imageView];
    imageView.image = [UIImage imageNamed:imageName];
    [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(view);
        make.leading.equalTo(view).offset(16);
        make.width.height.mas_equalTo(22);
    }];
    
    UILabel *titleLab = [[UILabel alloc] init];
    [view addSubview:titleLab];
    titleLab.font = [UIFont systemFontOfSize:17];
    titleLab.textColor = hz_getColor(@"000000");
    titleLab.text = item;
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(view).offset(46);
        make.top.bottom.trailing.equalTo(view);
    }];
    [self.labels addObject:titleLab];
    
    if (addSeparater) {
        UIView *separater = [[UIView alloc] init];
        [view addSubview:separater];
        separater.backgroundColor = hz_2_bgColor;
        [separater mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(view);
            make.bottom.trailing.equalTo(view);
            make.height.mas_equalTo(1.0);
        }];
    }
    
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [button addTarget:self action:@selector(clickButton:) forControlEvents:(UIControlEventTouchUpInside)];
    button.tag = [self.items indexOfObject:item];
    [view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    [self.buttons addObject:button];
    return view;
}

- (void)clickButton:(UIButton *)button {
    if (self.SelectBlock) {
        self.SelectBlock(button.tag);
    }
    
    [self removeFromSuperview];
}

@end

