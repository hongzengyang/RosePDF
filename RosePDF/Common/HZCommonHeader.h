//
//  Header.h
//  RosePDF
//
//  Created by THS on 2024/2/4.
//

#ifndef Header_h
#define Header_h

#import <HZUIKit/HZUIKit.h>
#import <HZFoundationKit/HZFoundationKit.h>
#import <Masonry/Masonry.h>





#define ScreenWidth     [[[UIApplication sharedApplication] windows] objectAtIndex:0].frame.size.width
#define ScreenHeight    [[[UIApplication sharedApplication] windows] objectAtIndex:0].frame.size.height

#define hz_safeTop      [UIView hz_safeTop]
#define hz_safeBottom   [UIView hz_safeBottom]

#define hz_getColor(x)               [UIColor hz_getColor:x]
#define hz_getColorWithAlpha(x,a)    [UIColor hz_getColor:x alpha:[NSString stringWithFormat:@"%lf",a]]


#define hz_1_bgColor      [UIColor hz_getColor:@"F2F1F6"]
#define hz_2_bgColor      [UIColor hz_getColor:@"E4E3EB"]
#define hz_1_textColor    [UIColor hz_getColor:@"000000"]
#define hz_2_textColor    [UIColor hz_getColor:@"666666"]

#endif /* Header_h */
