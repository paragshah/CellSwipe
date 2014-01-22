//
//  CSTableViewCell.h
//  CellSwipe
//
//  Created by Parag Shah on 12/16/13.
//  Copyright (c) 2013 www.paragshah.com. All rights reserved.
//

@class CSTableViewCell;

@protocol CSTableViewCellDelegate <NSObject>

@optional
- (void)tableViewCellMuteTapped: (CSTableViewCell *)cell;
- (void)tableViewCellMoreTapped: (CSTableViewCell *)cell;
- (BOOL)tableViewCellSwipeStarted: (CSTableViewCell *)cell;
- (void)tableViewCellSwipedOpened: (CSTableViewCell *)cell;

@end


@interface CSTableViewCell : UITableViewCell

@property (weak, nonatomic) id<CSTableViewCellDelegate> delegate;
@property (assign, nonatomic) BOOL actionViewIsVisible;

-(void)hideActionView:(BOOL)animated completion:(void(^)(void))callback;

@end
