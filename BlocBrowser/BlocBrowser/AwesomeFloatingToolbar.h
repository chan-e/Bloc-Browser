//
//  AwesomeFloatingToolbar.h
//  BlocBrowser
//
//  Created by Eddy Chan on 4/22/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AwesomeFloatingToolbar;

@protocol AwesomeFloatingToolbarDelegate <NSObject>

@optional

- (void)floatingToolbar:(AwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title;

@end

@interface AwesomeFloatingToolbar : UIView

- (instancetype)initWithFourTitles:(NSArray *)titles;
- (void)setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title;

@property (nonatomic, weak) id <AwesomeFloatingToolbarDelegate> delegate;

@end
