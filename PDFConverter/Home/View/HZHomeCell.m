//
//  HZHomeCell.m
//  RosePDF
//
//  Created by THS on 2024/2/23.
//

#import "HZHomeCell.h"
#import "HZCommonHeader.h"
#import "HZShareManager.h"
#import "HZHomeProjectItemView.h"

@interface HZHomeCell()
@property (nonatomic, strong) HZProjectModel *project;

@property (nonatomic, strong) UIImageView *thumbImageView;
@property (nonatomic, strong) UILabel *flagLab;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *countLab;
@property (nonatomic, strong) UILabel *timeLab;
@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) UIButton *shareBtn;
@property (nonatomic, strong) UIButton *selectBtn;
@end

@implementation HZHomeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self configView];
    }
    return self;
}

- (void)configView {
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.thumbImageView = [[UIImageView alloc] init];
    self.thumbImageView.backgroundColor = hz_getColor(@"F4F4F4");
    self.thumbImageView.layer.cornerRadius = 4;
    self.thumbImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.thumbImageView];
    self.thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.flagLab = [[UILabel alloc] init];
    [self.contentView addSubview:self.flagLab];
    self.flagLab.textAlignment = NSTextAlignmentCenter;
    self.flagLab.font = [UIFont systemFontOfSize:11 weight:(UIFontWeightMedium)];
    self.flagLab.textColor = hz_getColor(@"ffffff");
    self.flagLab.backgroundColor = hz_getColor(@"FF3B30");
    self.flagLab.layer.cornerRadius = 4;
    self.flagLab.layer.masksToBounds = YES;
    self.flagLab.text = NSLocalizedString(@"str_new", nil);
    
    self.titleLab = [[UILabel alloc] init];
    [self.contentView addSubview:self.titleLab];
    self.titleLab.font = [UIFont systemFontOfSize:17 weight:(UIFontWeightMedium)];
    self.titleLab.textColor = [UIColor blackColor];
    
    self.countLab = [[UILabel alloc] init];
    [self.contentView addSubview:self.countLab];
    self.countLab.font = [UIFont systemFontOfSize:15 weight:(UIFontWeightRegular)];
    self.countLab.textColor = hz_getColor(@"666666");
    
    self.timeLab = [[UILabel alloc] init];
    [self.contentView addSubview:self.timeLab];
    self.timeLab.font = [UIFont systemFontOfSize:14 weight:(UIFontWeightRegular)];
    self.timeLab.textColor = hz_getColor(@"666666");
    
    self.moreBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.contentView addSubview:self.moreBtn];
    [self.moreBtn setImage:[UIImage imageNamed:@"rose_home_more"] forState:(UIControlStateNormal)];
    [self.moreBtn addTarget:self action:@selector(clickMore) forControlEvents:(UIControlEventTouchUpInside)];
    self.moreBtn.backgroundColor = hz_getColor(@"F4F4F4");
    self.moreBtn.layer.cornerRadius = 6;
    self.moreBtn.layer.masksToBounds = YES;
    
    self.shareBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.contentView addSubview:self.shareBtn];
    [self.shareBtn setImage:[UIImage imageNamed:@"rose_homecell_share"] forState:(UIControlStateNormal)];
    [self.shareBtn addTarget:self action:@selector(clickShare) forControlEvents:(UIControlEventTouchUpInside)];
    self.shareBtn.backgroundColor = hz_getColor(@"F4F4F4");
    self.shareBtn.layer.cornerRadius = 6;
    self.shareBtn.layer.masksToBounds = YES;
    
    self.selectBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.contentView addSubview:self.selectBtn];
    self.selectBtn.userInteractionEnabled = NO;
    [self.selectBtn setImage:[UIImage imageNamed:@"rose_homeselect_n"] forState:(UIControlStateNormal)];
    [self.selectBtn setImage:[UIImage imageNamed:@"rose_homeselect_s"] forState:(UIControlStateSelected)];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self.thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(12);
        make.top.equalTo(self.contentView).offset(10);
        make.width.mas_equalTo(58);
        make.height.mas_equalTo(77);
    }];
    
    [self.flagLab sizeToFit];
    [self.flagLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(4);
        make.leading.equalTo(self.contentView).offset(10);
        make.width.mas_equalTo(self.flagLab.width + 10);
        make.height.mas_equalTo(18);
    }];
    
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.thumbImageView);
        make.trailing.equalTo(self.contentView).offset(-16);
        make.width.mas_equalTo(24);
        make.height.mas_equalTo(24);
    }];
    
    [self.shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.thumbImageView);
        make.trailing.equalTo(self.contentView).offset(-16);
        make.width.mas_equalTo(24);
        make.height.mas_equalTo(24);
    }];
    
    [self.selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-16);
        make.width.mas_equalTo(24);
        make.height.mas_equalTo(24);
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.thumbImageView);
        make.leading.equalTo(self.thumbImageView.mas_trailing).offset(8);
        make.trailing.equalTo(self.moreBtn.mas_leading).offset(-8);
        make.height.mas_equalTo(20);
    }];
    
    [self.countLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLab.mas_bottom).offset(13);
        make.leading.trailing.equalTo(self.titleLab);
        make.height.mas_equalTo(16);
    }];
    
    [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.thumbImageView);
        make.leading.trailing.equalTo(self.titleLab);
        make.height.mas_equalTo(15);
    }];
}

- (void)configWithProject:(HZProjectModel *)project isSelectMode:(BOOL)isSelectMode isSelect:(BOOL)isSelect {
    self.project = project;
    
    if (project.password.length > 0) {
        self.thumbImageView.image = [UIImage imageNamed:@"rose_homecell_lock"];
        self.thumbImageView.contentMode = UIViewContentModeCenter;
    }else {
        if (self.project.pageModels.count > 0) {
            UIImage *firstImage = [UIImage imageWithContentsOfFile:[[project.pageModels firstObject] resultPath]];
            self.thumbImageView.image = [firstImage hz_resizeImageToWidth:320];
        }else {
            self.thumbImageView.image = nil;
        }
    }
    
    self.flagLab.hidden = !project.newFlag;
    
    self.titleLab.text = [NSString stringWithFormat:@"%@.pdf",project.title];
    
    NSData *data = [NSData dataWithContentsOfFile:[project pdfPath]];
    self.countLab.text = [NSString stringWithFormat:@"%@ %@ - %@",@(self.project.pageModels.count),NSLocalizedString(@"str_pages", nil),[[NSFileManager defaultManager] hz_toMorestTwoFloatMBSize:data.length]];
    self.timeLab.text = [NSDate hz_dateTimeString2WithTime:project.createTime];
    
    if (isSelectMode) {
        self.selectBtn.hidden = NO;
        self.moreBtn.hidden = YES;
        self.shareBtn.hidden = YES;
        self.selectBtn.selected = isSelect;
    }else {
        self.selectBtn.hidden = YES;
        self.moreBtn.hidden = NO;
        self.shareBtn.hidden = NO;
    }
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
}

- (void)clickMore {
    if (self.clickMoreBlock) {
        self.clickMoreBlock();
    }
    
    HZHomeProjectItemView *itemView = [[HZHomeProjectItemView alloc] initWithProject:self.project];
    [[UIView hz_viewController].view addSubview:itemView];
}

- (void)clickShare {
    if (self.clickShareBlock) {
        self.clickShareBlock();
    }
    
    HZShareParam *param = [[HZShareParam alloc] init];
    param.project = self.project;
    param.relatedView = self.shareBtn;
    param.arrowDirection = UIPopoverArrowDirectionUp;
    [HZShareManager shareWithParam:param completionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
            
    }];
}

@end
