//
//  CSTableViewCell.m
//  CellSwipe
//
//  Created by Parag Shah on 12/16/13.
//  Copyright (c) 2013 www.paragshah.com. All rights reserved.
//

#import "CSTableViewCell.h"
#import "CSActionView.h"


static const CGFloat PAN_ELASTICITY_STARTING_POINT = 80.0f;
static const CGFloat PAN_ELASTICITY_FACTOR = 0.55f;

typedef void (^HideActionViewAnimationCompleteCallback)(void);


////////////////////////////////////////////////////////////////////////////////
// CSTableViewCell
////////////////////////////////////////////////////////////////////////////////

@interface CSTableViewCell() <UIGestureRecognizerDelegate, CSActionViewDataSource>
{
    CGFloat _currentTouchPositionX;
}

@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIButton *muteButton;
@property (nonatomic, strong) CSActionView *actionView;

@end


@implementation CSTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {

        // UIButtons for action view
        self.muteButton = [self buttonWithTitle:@"Mute" backgroundColor:[UIColor redColor]];
        self.moreButton = [self buttonWithTitle:@"More" backgroundColor:[UIColor lightGrayColor]];

        // UIView containing UIButtons to show underneath cell
        CSActionView *actionView = [[CSActionView alloc] initWithFrame:self.contentView.bounds];
        self.actionView = actionView;
        self.actionView.dataSource = self;
        [actionView addSubview:self.moreButton];
        [actionView addSubview:self.muteButton];
        [self insertSubview:actionView belowSubview:[self iOS7andUp] ? self : self.contentView];

        // UITableViewCell
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self clipsToBounds];

        // UIPanGestureRecognizer
        UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [recognizer setMinimumNumberOfTouches:1];
        [recognizer setMaximumNumberOfTouches:1];
        recognizer.delegate = self;
        [self addGestureRecognizer:recognizer];
    }

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect frame = self.actionView.frame;
    frame.size.height = self.contentView.frame.size.height;
    self.actionView.frame = frame;
}

#pragma mark - public methods

- (BOOL)actionViewIsVisible {
    return !self.actionView.hidden;
}

- (void)hideActionView:(BOOL)animated completion:(HideActionViewAnimationCompleteCallback)callback
{
    CGFloat x = 0.0f;
    CGFloat y = self.contentView.frame.origin.y;
    CGFloat w = self.contentView.frame.size.width;
    CGFloat h = self.contentView.frame.size.height;

    [UIView animateWithDuration:animated ? 0.3f : 0.0f
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.contentView.frame = CGRectMake(x, y, w, h);
                         [self.contentView layoutIfNeeded];
                     } completion:^(BOOL finished) {
        [self.actionView setHidden:YES];

        if (callback) {
            callback();
        }
    }
    ];
}

#pragma mark - private methods

- (void)showActionView:(BOOL)animated
{
    CGFloat x = -1 * [self.actionView maxWidth];
    CGFloat y = self.contentView.frame.origin.y;
    CGFloat w = self.contentView.frame.size.width;
    CGFloat h = self.contentView.frame.size.height;

    [UIView animateWithDuration:animated ? 0.3f : 0.0f
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.contentView.frame = CGRectMake(x, y, w, h);
                         [self.contentView layoutIfNeeded];
                     } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(tableViewCellSwipedOpened:)]) {
            [self.delegate tableViewCellSwipedOpened:self];
        }
    }
    ];
}

- (UIButton *)buttonWithTitle:(NSString *)title backgroundColor:(UIColor *)backgroundColor
{
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(actionViewButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = backgroundColor;

    return button;
}

- (void)actionViewButtonTapped:(UIButton *)sender
{
    if (sender == self.moreButton && [self.delegate respondsToSelector:@selector(tableViewCellMoreTapped:)]) {
        [self.delegate tableViewCellMoreTapped:self];
    } else if (sender == self.muteButton && [self.delegate respondsToSelector:@selector(tableViewCellMuteTapped:)]) {
        [self.delegate tableViewCellMuteTapped:self];
    }

    [self hideActionView:YES completion:nil];
}

- (BOOL)iOS7andUp
{
    NSComparisonResult result = [[UIDevice currentDevice].systemVersion compare:@"7.0" options:NSNumericSearch];
    return result == NSOrderedSame || result == NSOrderedDescending;
}

#pragma mark - UIGestureRecognizerDelegate

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    if (self.selected || ![recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return;
    }

    CGPoint touchPoint = [recognizer locationInView:self.contentView];
    CGFloat touchPositionX = touchPoint.x;
    CGFloat maxWidth = -1 * [self.actionView maxWidth];

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(tableViewCellSwipeStarted:)]) {
            if (![self.delegate tableViewCellSwipeStarted:self]) {
                return;
            }
        }

        _currentTouchPositionX = touchPositionX;
        [self.actionView setHidden:NO];

    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        if (self.actionView.hidden) {
            return;
        }

        CGPoint translation = [recognizer translationInView:recognizer.view];
        CGFloat panOffset = translation.x;

        if (ABS(translation.x) > PAN_ELASTICITY_STARTING_POINT) {
            CGFloat width = CGRectGetWidth(self.frame);
            CGFloat offset = abs(translation.x);
            panOffset = (offset * PAN_ELASTICITY_FACTOR * width) / (offset * PAN_ELASTICITY_FACTOR + width);
            panOffset *= translation.x < 0 ? -1.0f : 1.0f;
            if (PAN_ELASTICITY_STARTING_POINT > 0) {
                panOffset = translation.x > 0
                        ? panOffset + PAN_ELASTICITY_STARTING_POINT / 2
                        : panOffset - PAN_ELASTICITY_STARTING_POINT / 2;
            }
        }

        CGPoint actualTranslation = CGPointMake(panOffset, translation.y);

        if (actualTranslation.x < 0) {
            if (self.contentView.frame.origin.x != maxWidth || actualTranslation.x < maxWidth) {
                self.contentView.frame = CGRectOffset(self.contentView.bounds, actualTranslation.x, 0);
            }
        } else {
            CGFloat delta = (CGFloat)fabs(touchPositionX - _currentTouchPositionX);
            CGRect frame = self.contentView.frame;
            frame.origin.x = MIN(0, frame.origin.x + delta);
            self.contentView.frame = frame;
        }

    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        CGFloat minWidth = maxWidth / 3;
        if (self.contentView.frame.origin.x < minWidth) {
            [self showActionView:YES];
        } else {
            [self hideActionView:YES completion:nil];
        }

        if (self.contentView.frame.origin.x < minWidth) {
            [self showActionView:YES];
        } else {
            [self hideActionView:YES completion:nil];
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self];
        return fabs(translation.x) > fabs(translation.y);
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

#pragma mark - CSActionView

- (NSUInteger)numberOfButtonsInActionView:(CSActionView *)actionView
{
    return 2;
}

- (UIButton *)actionView:(CSActionView *)actionView buttonAtIndex:(NSUInteger)index
{
    switch (index) {
        case 0: return self.muteButton;
        case 1: return self.moreButton;
        default: return nil;
    }
}

@end
