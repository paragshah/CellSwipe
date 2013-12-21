//
//  CSActionView.m
//  CellSwipe
//
//  Created by Parag Shah on 12/17/13.
//  Copyright (c) 2013 www.paragshah.com. All rights reserved.
//

#import "CSActionView.h"


@implementation CSActionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self clipsToBounds];
        [self setHidden:YES];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (self.dataSource) {
        CGFloat totalWidth = self.bounds.size.width;
        CGFloat totalHeight = self.bounds.size.height;
        CGFloat previousWidth = 0.0f;
        self.maxWidth = 0.0f;

        for (NSUInteger i = 0; i < [self.dataSource numberOfButtonsInActionView:self]; i++) {
            UIButton *button = [self.dataSource actionView:self buttonAtIndex:i];

            if (button) {
                [button sizeToFit];
                CGFloat w = button.bounds.size.width + 20.0f;  // +button padding
                CGFloat x = totalWidth - w - previousWidth;
                button.frame = CGRectMake(x, 0, w, totalHeight - 0.5);

                previousWidth = w;
                self.maxWidth += w;
            }
        }
    }
}

@end
