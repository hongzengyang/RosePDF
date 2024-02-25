//
//  HZSortCell.m
//  RosePDF
//
//  Created by THS on 2024/2/21.
//

#import "HZSortCell.h"
#import "HZCommonHeader.h"

@interface HZSortCell()

@property (nonatomic, strong) UIImageView *thumbImageView;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *timeLab;
@property (nonatomic, strong) UIImageView *rightImageView;

@end

@implementation HZSortCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configView];
    }
    return self;
}

- (void)configView {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 10;
    self.contentView.layer.masksToBounds = YES;
    
    self.thumbImageView = [[UIImageView alloc] init];
    self.thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.thumbImageView.layer.masksToBounds = YES;
    self.thumbImageView.layer.cornerRadius = 4;
    [self.contentView addSubview:self.thumbImageView];
    
    self.titleLab = [[UILabel alloc] init];
    self.titleLab.font = [UIFont systemFontOfSize:17];
    self.titleLab.textColor = hz_getColor(@"000000");
    [self.contentView addSubview:self.titleLab];
    
    self.timeLab = [[UILabel alloc] init];
    self.timeLab.font = [UIFont systemFontOfSize:15];
    self.timeLab.textColor = hz_getColor(@"666666");
    [self.contentView addSubview:self.timeLab];
    
    self.rightImageView = [[UIImageView alloc] init];
    self.rightImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.rightImageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(12);
        make.top.equalTo(self.contentView).offset(10);
        make.width.mas_equalTo(58);
        make.height.mas_equalTo(77);
    }];
    [self.rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView).offset(-16);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(28);
        make.height.mas_equalTo(28);
    }];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.thumbImageView).offset(16);
        make.leading.equalTo(self.thumbImageView.mas_trailing).offset(8);
        make.trailing.equalTo(self.rightImageView.mas_leading).offset(-2);
    }];
    [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLab.mas_bottom).offset(10);
        make.leading.trailing.equalTo(self.titleLab);
    }];
}

- (void)configWithPage:(HZPageModel *)page {
    UIImage *originImage = [UIImage imageWithContentsOfFile:[page originPath]];
    originImage = [originImage hz_resizeImageToWidth:540];
    self.thumbImageView.image = originImage;
    
    self.titleLab.text = page.title;
    self.timeLab.text = [NSString stringWithFormat:@"%@",[NSDate hz_dateTimeStringWithTime:page.createTime]];
    
    self.rightImageView.image = [UIImage imageNamed:@"rose_sort_drag"];
}

@end
