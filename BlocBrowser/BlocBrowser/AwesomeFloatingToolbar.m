//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Eddy Chan on 4/22/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"

@interface AwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, strong) UIPanGestureRecognizer       *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer     *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation AwesomeFloatingToolbar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFourTitles:(NSArray *)titles {
    // First, call the superclass (UIView)'s initializer,
    // to make sure we do all that setup first
    self = [super init];
    
    if (self) {
        // Save the titles, and set the 4 colors
        self.currentTitles = titles;

        self.colors        = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                               [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97 /255.0 alpha:1],
                               [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                               [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71 /255.0 alpha:1]];
        
        NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
        
        // Make the 4 buttons
        for (NSString *currentTitle in self.currentTitles) {
            NSUInteger currentTitleIndex  = [self.currentTitles indexOfObject:currentTitle]; // 0 through 3
            
            NSString  *titleForThisButton = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor   *colorForThisButton = [self.colors        objectAtIndex:currentTitleIndex];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.enabled   = NO;
            
            button.titleLabel.font = [UIFont systemFontOfSize:10];
            
            [button setTitle     :titleForThisButton   forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            
            button.backgroundColor = colorForThisButton;
            button.alpha           = 0.25;
            
            
            [button addTarget:self
                       action:@selector(buttonTapped:)
             forControlEvents:UIControlEventTouchUpInside];
            
            [buttonsArray addObject:button];
        }
        
        self.buttons = buttonsArray;
        
        for (UIButton *thisButton in self.buttons) {
            [self addSubview:thisButton];
        }
        
        self.panGesture       = [[UIPanGestureRecognizer       alloc]
                                 initWithTarget:self action:@selector(panFired:)];
        self.pinchGesture     = [[UIPinchGestureRecognizer     alloc]
                                 initWithTarget:self action:@selector(pinchFired:)];
        self.longPressGesture = [[UILongPressGestureRecognizer alloc]
                                 initWithTarget:self action:@selector(longPressFired:)];
        
        [self addGestureRecognizer:self.panGesture];
        [self addGestureRecognizer:self.pinchGesture];
        [self addGestureRecognizer:self.longPressGesture];
    }
    
    return self;
}

- (void)layoutSubviews {
    // Set the frames for the 4 buttons
    for (UILabel *thisButton in self.buttons) {
        NSUInteger currentLabelIndex = [self.buttons indexOfObject:thisButton];
        
        CGFloat buttonHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat buttonWidth  = CGRectGetWidth(self.bounds)  / 2;
        CGFloat buttonX      = 0;
        CGFloat buttonY      = 0;
        
        // Adjust labelX and labelY for each button
        if (currentLabelIndex < 2) {
            // 0 or 1, so on top
            buttonY = 0;
        } else {
            // 2 or 3, so on bottom
            buttonY = CGRectGetHeight(self.bounds) / 2;
        }
        
        // Is currentLabelIndex evenly divisible by 2?
        if (currentLabelIndex % 2 == 0) {
            // 0 or 2, so on the left
            buttonX = 0;
        } else {
            // 1 or 3, so on the right
            buttonX = CGRectGetWidth(self.bounds)  / 2;
        }
        
        thisButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
    }
    
}

- (void)buttonTapped:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
        [self.delegate floatingToolbar:self didSelectButtonWithTitle:button.currentTitle];
    }
}

#pragma mark - Gesture Handling

- (void)panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

- (void)pinchFired:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPinchWithScale:)]) {
            [self.delegate floatingToolbar:self didTryToPinchWithScale:recognizer.scale];
        }
        recognizer.scale = 1.0;
    }
}

- (void)longPressFired:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // Rotate the colors clockwise
        self.colors = @[self.colors[2], self.colors[0], self.colors[3], self.colors[1]];
        
        // Assign the labels with new rotated background colors
        [self.buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ((UIButton *) obj).backgroundColor = [self.colors objectAtIndex:idx];
        }];
    }
}

#pragma mark - Button Enabling

- (void)setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UIButton *button = [self.buttons objectAtIndex:index];
        button.enabled   = enabled;
        button.alpha     = enabled ? 1.0 : 0.25;
    }
}

@end
