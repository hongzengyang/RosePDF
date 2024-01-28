//
//  NSString+HZCategory.m
//  HZFoundationKit
//
//  Created by THS on 2024/1/23.
//

#import "NSString+HZCategory.h"

@implementation NSString (HZCategory)

+ (BOOL)hz_isEmpty:(NSString *)string {
    if (!string) {
        return YES;
    }
    if (string.length == 0) {
        return YES;
    }
    return NO;
}

- (CGSize)hz_sizeWithFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode {
    CGSize result;
    if (!font) font = [UIFont systemFontOfSize:12];
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = font;
        if (lineBreakMode != NSLineBreakByWordWrapping) {
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineBreakMode = lineBreakMode;
            attr[NSParagraphStyleAttributeName] = paragraphStyle;
        }
        CGRect rect = [self boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attr context:nil];
        result = rect.size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
    return result;
}

- (CGFloat)hz_widthWithFont:(UIFont *)font {
    CGSize size = [self hz_sizeWithFont:font size:CGSizeMake(HUGE, HUGE) mode:NSLineBreakByWordWrapping];
    return size.width;
}

- (CGFloat)hz_heightWithFont:(UIFont *)font width:(CGFloat)width {
    CGSize size = [self hz_sizeWithFont:font size:CGSizeMake(width, HUGE) mode:NSLineBreakByWordWrapping];
    return size.height;
}

- (NSString *)hz_lastPathComponent {
    return [self lastPathComponent];
}

- (NSString *)hz_stringByDeletingLastPathComponent {
    return [self stringByDeletingLastPathComponent];
}

- (NSString *)hz_pathExtension {
    return [self pathExtension];
}

- (NSString *)hz_stringByDeletingPathExtension {
    return [self stringByDeletingPathExtension];
}

- (NSString *)hz_fileName {
    return [[self lastPathComponent] stringByDeletingPathExtension];
}

@end
