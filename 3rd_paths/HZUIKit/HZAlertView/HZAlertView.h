//
//  HZAlertView.h
//  DTFoundation
//
//  Created by Oliver Drobnik on 11/22/12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import "HZWeakSupport.h"
#import <UIKit/UIKit.h>

// the block to execute when an alert button is tapped
typedef void (^HZAlertViewBlock)(void);

/**
 Extends UIAlertView with support for blocks.
 */

@interface HZAlertView : UIAlertView

/**
* Initializes the alert view. Add buttons and their blocks afterwards.
 @param title The alert title
 @param message The alert message
*/
- (id)initWithTitle:(NSString *)title message:(NSString *)message;

/**
 Adds a button to the alert view

 @param title The title of the new button.
 @param block The block to execute when the button is tapped.
 @returns The index of the new button. Button indices start at 0 and increase in the order they are added.
 */
- (NSInteger)addButtonWithTitle:(NSString *)title block:(HZAlertViewBlock)block;

/**
 Same as above, but for a cancel button.
 @param title The title of the cancel button.
 @param block The block to execute when the button is tapped.
 @returns The index of the new button. Button indices start at 0 and increase in the order they are added.
 */
- (NSInteger)addCancelButtonWithTitle:(NSString *)title block:(HZAlertViewBlock)block;

/**
 Set a block to be run on alertViewCancel:.
 @param block The block to execute.
 */
- (void)setCancelBlock:(HZAlertViewBlock)block;


/**
 * Use the alertViewDelegate when you want to to receive UIAlertViewDelegate messages.
 */
@property (nonatomic, DT_WEAK_PROPERTY) id<UIAlertViewDelegate> alertViewDelegate;

@end



@interface HZAlertViewManager : NSObject

@property (nonatomic, strong)NSMutableArray * alertViewArray;

+ (instancetype)shareAlertViewRecorder;

-(void)addWithAlertView:(HZAlertView *)alertView;
-(void)clearAlertView;
-(BOOL)isKeyBoardShown;
@end
