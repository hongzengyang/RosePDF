//
//  NSString+HZCategory.h
//  HZFoundationKit
//
//  Created by THS on 2024/1/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (HZCategory)

+ (BOOL)hz_isEmpty:(NSString *)string;

/**
 Returns the size of the string if it were rendered with the specified constraints.
 
 @param font          The font to use for computing the string size.
 
 @param size          The maximum acceptable size for the string. This value is
 used to calculate where line breaks and wrapping would occur.
 
 @param lineBreakMode The line break options for computing the size of the string.
 For a list of possible values, see NSLineBreakMode.
 
 @return              The width and height of the resulting string's bounding box.
 These values may be rounded up to the nearest whole number.
 */
- (CGSize)hz_sizeWithFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode;

/**
 Returns the width of the string if it were to be rendered with the specified
 font on a single line.
 
 @param font  The font to use for computing the string width.
 
 @return      The width of the resulting string's bounding box. These values may be
 rounded up to the nearest whole number.
 */
- (CGFloat)hz_widthWithFont:(UIFont *)font;

/**
 Returns the height of the string if it were rendered with the specified constraints.
 
 @param font   The font to use for computing the string size.
 
 @param width  The maximum acceptable width for the string. This value is used
 to calculate where line breaks and wrapping would occur.
 
 @return       The height of the resulting string's bounding box. These values
 may be rounded up to the nearest whole number.
 */
- (CGFloat)hz_heightWithFont:(UIFont *)font width:(CGFloat)width;

/*
 "/xxxx/Documents/DownLoad/books/2013_50.zip"
 return: 2013_50.zip
 */
- (NSString *)hz_lastPathComponent;
/*
 "/xxxx/Documents/DownLoad/books/2013_50.zip"
 return: /xxxx/Documents/DownLoad/books
 */
- (NSString *)hz_stringByDeletingLastPathComponent;
/*
 "/xxxx/Documents/DownLoad/books/2013_50.zip"
 return: zip
 */
- (NSString *)hz_pathExtension;
/*
 "/xxxx/Documents/DownLoad/books/2013_50.zip"
 return: /xxxx/Documents/DownLoad/books/2013_50
 */
- (NSString *)hz_stringByDeletingPathExtension;
/*
 "/xxxx/Documents/DownLoad/books/2013_50.zip"
 return: 2013_50
 */
- (NSString *)hz_fileName;

@end

NS_ASSUME_NONNULL_END
