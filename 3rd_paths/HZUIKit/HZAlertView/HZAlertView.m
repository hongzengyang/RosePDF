//
//  HZAlertView.m
//  DTFoundation
//
//  Created by Oliver Drobnik on 11/22/12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import "HZAlertView.h"

@interface HZAlertViewManager ()

@property (atomic,assign)BOOL keyBoardShown;

@end

@implementation HZAlertViewManager


+ (instancetype)shareAlertViewRecorder
{
    static HZAlertViewManager *recoder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(recoder == nil){
            recoder = [[HZAlertViewManager alloc] init];
            
        }
    });
    return recoder;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.alertViewArray = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name: UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidHide:) name: UIKeyboardDidHideNotification object:nil];
    }
    return self;
}

-(void)keyboardDidShow:(NSNotification *)noti
{
    _keyBoardShown = YES;
}

-(void)keyboardDidHide:(NSNotification *)noti
{
    _keyBoardShown = NO;
}

-(BOOL)isKeyBoardShown
{
//    NSLog(@"- keyboard is shown : %d -",_keyBoardShown);
    return _keyBoardShown;
}

#pragma mark -

-(void)addWithAlertView:(HZAlertView *)alertView
{
    if (alertView)
    {
        [_alertViewArray addObject:alertView];
    }
}

-(void)clearAlertView
{
    [_alertViewArray removeAllObjects];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


@interface HZAlertView() <UIAlertViewDelegate>

@end

@implementation HZAlertView
{
	NSMutableDictionary *_actionsPerIndex;

	HZAlertViewBlock _cancelBlock;
}

- (void)dealloc
{
	[super setDelegate:nil];
	self.alertViewDelegate = nil;
}

// designated initializer
- (id)init
{
    self = [super init];
    if (self)
    {
        _actionsPerIndex = [[NSMutableDictionary alloc] init];
        [super setDelegate:self];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message
{
    return [self initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
	self = [self init];
	if (self)
	{
        self.title = title;
        self.message = message;
        
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
        if (cancelButtonTitle) {
            [self addCancelButtonWithTitle:cancelButtonTitle block:nil];
        }
        
        self.alertViewDelegate = delegate;
	}
	return self;
}

- (NSInteger)addButtonWithTitle:(NSString *)title block:(HZAlertViewBlock)block
{
	NSInteger retIndex = [self addButtonWithTitle:title];

	if (block)
	{
		NSNumber *key = [NSNumber numberWithInteger:retIndex];
		[_actionsPerIndex setObject:[block copy] forKey:key];
	}

	return retIndex;
}

- (NSInteger)addCancelButtonWithTitle:(NSString *)title block:(HZAlertViewBlock)block
{
	NSInteger retIndex = [self addButtonWithTitle:title block:block];
	[self setCancelButtonIndex:retIndex];

	return retIndex;
}

- (void)setCancelBlock:(HZAlertViewBlock)block
{
	_cancelBlock = block;
}

# pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSNumber *key = [NSNumber numberWithInteger:buttonIndex];
    
	HZAlertViewBlock block = [_actionsPerIndex objectForKey:key];
	if (block)
	{
		block();
	}

	if ([self.alertViewDelegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
	{
		[self.alertViewDelegate alertView:self clickedButtonAtIndex:buttonIndex];
	}
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
	if (_cancelBlock)
	{
		_cancelBlock();
	}

	if ([self.alertViewDelegate respondsToSelector:@selector(alertViewCancel:)])
	{
		[self.alertViewDelegate alertViewCancel:self];
	}
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
	if ([self.alertViewDelegate respondsToSelector:@selector(willPresentAlertView:)])
	{
		[self.alertViewDelegate willPresentAlertView:self];
	}
}

- (void)didPresentAlertView:(UIAlertView *)alertView
{
	if ([self.alertViewDelegate respondsToSelector:@selector(didPresentAlertView:)])
	{
		[self.alertViewDelegate didPresentAlertView:self];
	}
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [[HZAlertViewManager shareAlertViewRecorder] clearAlertView];
    
	if ([self.alertViewDelegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)])
	{
		[self.alertViewDelegate alertView:self willDismissWithButtonIndex:buttonIndex];
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if ([self.alertViewDelegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)])
	{
		[self.alertViewDelegate alertView:self didDismissWithButtonIndex:buttonIndex];
	}
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
	if ([self.alertViewDelegate respondsToSelector:@selector(alertViewShouldEnableFirstOtherButton:)])
	{
		return [self.alertViewDelegate alertViewShouldEnableFirstOtherButton:self];
	}

	return YES;
}


#pragma mark - Properties


- (void)setDelegate:(id <UIAlertViewDelegate>)delegate
{
	if (delegate)
	{
		NSLog(@"Calling setDelegate is not supported! Use setAlertViewDelegate instead");
	}
}
-(void)show
{
    NSMutableArray *array = [HZAlertViewManager shareAlertViewRecorder].alertViewArray;
    //当已经有alert在了，就不要再弹出来了
    if (array && array.count > 0)
    {
        return;
    }
    
    if ([HZAlertViewManager shareAlertViewRecorder].isKeyBoardShown)
    {
        [[HZAlertViewManager shareAlertViewRecorder] addWithAlertView:self];
        
        //延迟执行的原因是，ios8以下的UIAlertView 的显示执行的动画和键盘resignFirstResponder的动画冲突，要延迟0.6秒，等待键盘完成动画，再显示alert，网络上给出的建议是ios8以上使用UIalertviewcontroller 参考：http://stackoverflow.com/questions/30129278/keyboard-pops-up-after-uialertview-is-dismissed-on-ios-8-3-for-ipad
        
        //先收回键盘
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
        
        [self performSelector:@selector(superShowMethod) withObject:nil afterDelay:0.6];
    }
    else
    {
        if ([[NSThread currentThread] isMainThread])
        {
            [super show];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [super show];
            });
        }
    }

}
-(void)superShowMethod
{
    if ([[NSThread currentThread] isMainThread])
    {
        [super show];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [super show];
        });
    }
}
@end
