//
//  HZActionSheet.m
//  DTFoundation
//
//  Created by Oliver Drobnik on 08.06.12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import "HZActionSheet.h"
#import "HZWeakSupport.h"

@interface HZActionSheet () <UIActionSheetDelegate>

@end

@implementation HZActionSheet
{
	NSMutableDictionary *_actionsPerIndex;
}

// designated initializer
- (instancetype)init
{
	self = [super init];
	if (self)
	{
		_actionsPerIndex = [[NSMutableDictionary alloc] init];
		[super setDelegate:self];
        
        //注册程序进入后台通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];

	}
	return self;
}

- (instancetype)initWithTitle:(NSString *)title
{
	return [self initWithTitle:title delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
}

- (instancetype)initWithTitle:(NSString *)title delegate:(id<UIActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
	self = [self init];
	if (self)
	{
		self.title = title;

		if (otherButtonTitles != nil) {
			[self addButtonWithTitle:otherButtonTitles];
			va_list args;
			va_start(args, otherButtonTitles);
			NSString *title = nil;
			while( (title = va_arg(args, NSString *)) ) {
				[self addButtonWithTitle:title];
			}
			va_end(args);
		}

		if (destructiveButtonTitle) {
			[self addDestructiveButtonWithTitle:destructiveButtonTitle block:nil];
		}
		if (cancelButtonTitle) {
			[self addCancelButtonWithTitle:cancelButtonTitle block:nil];
		}

		self.actionSheetDelegate = delegate;
	}

	return self;
}

- (void)dealloc
{
	[super setDelegate:nil];
	self.actionSheetDelegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSInteger)addButtonWithTitle:(NSString *)title block:(HZActionSheetBlock)block
{
	NSInteger retIndex = [self addButtonWithTitle:title];

	if (block)
	{
		NSNumber *key = [NSNumber numberWithInteger:retIndex];
		[_actionsPerIndex setObject:[block copy] forKey:key];
	}

	return retIndex;
}

- (NSInteger)addDestructiveButtonWithTitle:(NSString *)title block:(HZActionSheetBlock)block
{
	NSInteger retIndex = [self addButtonWithTitle:title block:block];
	[self setDestructiveButtonIndex:retIndex];

	return retIndex;
}

- (NSInteger)addCancelButtonWithTitle:(NSString *)title
{
	return [self addCancelButtonWithTitle:title block:nil];
}

- (NSInteger)addCancelButtonWithTitle:(NSString *)title block:(HZActionSheetBlock)block
{
	NSInteger retIndex = [self addButtonWithTitle:title block:block];
	[self setCancelButtonIndex:retIndex];

	return retIndex;
}

#pragma mark - UIActionSheetDelegate (forwarded)

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
	if ([self.actionSheetDelegate respondsToSelector:@selector(actionSheetCancel:)])
	{
		[self.actionSheetDelegate actionSheetCancel:actionSheet];
	}
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
	if ([self.actionSheetDelegate respondsToSelector:@selector(willPresentActionSheet:)])
	{
		[self.actionSheetDelegate willPresentActionSheet:actionSheet];
	}
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet
{
	if ([self.actionSheetDelegate respondsToSelector:@selector(didPresentActionSheet:)])
	{
		[self.actionSheetDelegate didPresentActionSheet:actionSheet];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if ([self.actionSheetDelegate respondsToSelector:@selector(actionSheet:willDismissWithButtonIndex:)])
	{
		[self.actionSheetDelegate actionSheet:actionSheet willDismissWithButtonIndex:buttonIndex];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (_updateStatusWhenDismiss)
    {
        [[UIApplication sharedApplication].keyWindow.rootViewController setNeedsStatusBarAppearanceUpdate];
    }
	if ([self.actionSheetDelegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)])
	{
		[self.actionSheetDelegate actionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSNumber *key = [NSNumber numberWithInteger:buttonIndex];

	HZActionSheetBlock block = [_actionsPerIndex objectForKey:key];

	if (block)
	{
		block();
	}

	if ([self.actionSheetDelegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)])
	{
		[self.actionSheetDelegate actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
	}
}

- (BOOL)shouldDismissOnEnterBackground
{
	return NO;
}

-(void)appDidEnterBackground
{
	if ([self shouldDismissOnEnterBackground])
    {
        [self dismissWithClickedButtonIndex:self.cancelButtonIndex animated:NO];
    }
}

#pragma mark - Properties

- (void)setDelegate:(id <UIActionSheetDelegate>)delegate
{
	if (delegate)
	{
		NSLog(@"Calling setDelegate is not supported! Use setActionSheetDelegate instead");
	}
}

@end
