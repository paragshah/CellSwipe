//
//  CSActionView.h
//  CellSwipe
//
//  Created by Parag Shah on 12/16/13.
//  Copyright (c) 2013 www.paragshah.com. All rights reserved.
//

@class CSActionView;

@protocol CSActionViewDataSource <NSObject>

- (NSUInteger)numberOfButtonsInActionView:(CSActionView *)actionView;
- (UIButton *)actionView:(CSActionView *)actionView buttonAtIndex:(NSUInteger)index;

@end


@interface CSActionView : UIView

@property (strong, nonatomic) NSArray* buttons;
@property (weak, nonatomic) id<CSActionViewDataSource> dataSource;
@property (assign, nonatomic) CGFloat maxWidth;

@end
