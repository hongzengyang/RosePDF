//
//  HZAssetsTypeView.h
//  HZAssetsPicker
//
//  Created by hzy on 2024-05-01.
//

#import <UIKit/UIKit.h>

@protocol HZAssetsTypeViewDelegate <NSObject>

- (void)assetsTypeViewDidClickCamera;
- (void)assetsTypeViewDidClickPhoto;
- (void)assetsTypeViewDidClickFile;

@end


@interface HZAssetsTypeView : UIView

@property (nonatomic, weak) id<HZAssetsTypeViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame enableFile:(BOOL)enableFile;

@end

