//
//  HZSelectPopView.m
//  RosePDF
//
//  Created by THS on 2024/2/21.
//

#import "HZSelectPopView.h"
#import "HZCommonHeader.h"

@interface HZSelectPopView()

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UIImageView *selectImageView;
@property (nonatomic, strong) NSMutableArray <UIButton *>*buttons;
@property (nonatomic, strong) NSMutableArray <UILabel *>*labels;

@property (nonatomic, strong) NSArray<NSString *> *items;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, weak) UIView *inView;
@property (nonatomic, weak) UIView *relatedView;
@property (nonatomic, assign) HZSelectPopType type;
@property (nonatomic, copy) void(^SelectBlock)(NSInteger);


@property (nonatomic, assign) CGFloat itemHeight;

@end

@implementation HZSelectPopView

+ (void)popWithItems:(NSArray<NSString *> *)items index:(NSInteger)index inView:(UIView *)inView relatedView:(UIView *)relatedView type:(HZSelectPopType)type selectBlock:(void (^)(NSInteger))selectBlock {
    HZSelectPopView *popView = [[HZSelectPopView alloc] initWithItems:items index:index inView:inView relatedView:relatedView type:type selectBlock:selectBlock];
    [inView addSubview:popView];
    [popView configView];
}

- (instancetype)initWithItems:(NSArray<NSString *> *)items index:(NSInteger)index inView:(UIView *)inView relatedView:(UIView *)relatedView type:(HZSelectPopType)type selectBlock:(void (^)(NSInteger))selectBlock {
    if (self = [super init]) {
        self.items = items;
        self.currentIndex = index;
        self.inView = inView;
        self.relatedView = relatedView;
        self.type = type;
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
    [containerView setSize:CGSizeMake(228, self.itemHeight * self.items.count)];
    containerView.layer.cornerRadius = 16;
    containerView.layer.masksToBounds = YES;
    
    [self addSubview:containerView];
    switch (self.type) {
        case HZSelectPopType_quality:{
            [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.equalTo(self.relatedView);
                make.bottom.equalTo(self.relatedView.mas_top);
                make.width.mas_equalTo(containerView.width);
                make.height.mas_equalTo(containerView.height);
            }];
        }
            break;
        case HZSelectPopType_margin:{
            [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.equalTo(self.relatedView);
                make.top.equalTo(self.relatedView.mas_bottom);
                make.width.mas_equalTo(containerView.width);
                make.height.mas_equalTo(containerView.height);
            }];
        }
            break;
        default:
            break;
    }
    self.containerView = containerView;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThickMaterialLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [containerView addSubview:blurEffectView];
    [blurEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(containerView);
    }];
    
    [self.items enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *itemView = [self createItemViewWithItem:obj addSeparater:(idx != self.items.count -1) width:self.width];
        [containerView addSubview:itemView];
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(containerView);
            make.height.mas_equalTo(self.itemHeight);
            make.top.mas_equalTo(idx * self.itemHeight);
        }];
    }];
    
    self.selectImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rose_pdf_size_select"]];
    self.selectImageView.contentMode = UIViewContentModeCenter;
    [containerView addSubview:self.selectImageView];
    [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(containerView).offset(16);
        make.width.height.mas_equalTo(22);
    }];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    UIView *shadow = [[UIView alloc] init];
//    {//shadow
//        [self insertSubview:shadow belowSubview:containerView];
//        [shadow setFrame:CGRectInset(containerView.frame, 16, 16)];
//        shadow.layer.shadowColor = hz_getColorWithAlpha(@"000000", 0.2).CGColor;
//        shadow.layer.shadowOffset = CGSizeMake(20, -3);
//        shadow.layer.shadowRadius = 10;
//        shadow.layer.shadowOpacity = 0.5;
//        shadow.backgroundColor = [UIColor whiteColor];
//    }
    
    [self updateSelectImageView];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    CGRect frame = containerView.frame;
    if (self.type == HZSelectPopType_quality) {
        containerView.layer.anchorPoint = CGPointMake(1, 1);
    }
    containerView.frame = frame;
    containerView.alpha = 0.3;
    containerView.transform = CGAffineTransformScale(containerView.transform, 0.1, 0.1);
    [UIView animateWithDuration:0.15 animations:^{
        containerView.transform = CGAffineTransformIdentity;
        containerView.alpha = 1.0;
    }];
}

- (void)updateSelectImageView {
    [self.buttons enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == self.currentIndex) {
            self.labels[idx].textColor = hz_main_color;
            [self.selectImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(obj);
                make.leading.equalTo(self.containerView).offset(16);
                make.width.height.mas_equalTo(22);
            }];
        }else {
            self.labels[idx].textColor = hz_getColor(@"000000");
        }
    }];
}


- (UIView *)createItemViewWithItem:(NSString *)item addSeparater:(BOOL)addSeparater width:(CGFloat)width {
    UIView *view = [[UIView alloc] init];
    view.size = CGSizeMake(width, self.itemHeight);
    
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
    self.currentIndex = button.tag;
    [self updateSelectImageView];
    
    if (self.SelectBlock) {
        self.SelectBlock(self.currentIndex);
    }
    
    [self removeFromSuperview];
}

@end
