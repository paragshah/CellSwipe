//
//  CSTableViewController.m
//  CellSwipe
//
//  Created by Parag Shah on 12/16/13.
//  Copyright (c) 2013 www.paragshah.com. All rights reserved.
//

#import "CSTableViewController.h"
#import "CSTableViewCell.h"


static NSString * const CELL_IDENTIFIER = @"Cell";


@interface CSTableViewController() <CSTableViewCellDelegate>

@property (nonatomic, strong) CSTableViewCell *swipedCell;

@end


@implementation CSTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"UITableViewCell Swipe Test";

        if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        }
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[CSTableViewCell class] forCellReuseIdentifier:CELL_IDENTIFIER];
}

#pragma mark private

-(void)hideActionViewForSwipedCell
{
    if (self.swipedCell) {
        [self.swipedCell hideActionView:YES completion:^{
            self.swipedCell = nil;
        }];
    }
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    if (cell == nil) {
        cell = [[CSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    }

    cell.delegate = self;
    cell.textLabel.text = [NSString stringWithFormat:@"cell abc def ghi jkl %d", indexPath.row];

    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideActionViewForSwipedCell];
    return indexPath;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    CSTableViewCell *cell = (CSTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];

    if (self.swipedCell && cell != self.swipedCell) {
        [self hideActionViewForSwipedCell];
    }

    // if action view is currently visible somewhere, then don't allow highlight
    // on this cell
    if (cell && cell.actionViewIsVisible) {
        [self hideActionViewForSwipedCell];
        return NO;
    }

    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideActionViewForSwipedCell];
}

#pragma mark - CSTableViewCellDelegate

- (void)tableViewCellMuteTapped: (CSTableViewCell *)cell
{
    NSLog(@"mute tapped!");
}

- (void)tableViewCellMoreTapped: (CSTableViewCell *)cell
{
    NSLog(@"more tapped!");
}

- (BOOL)tableViewCellSwipeStarted: (CSTableViewCell *)cell
{
    if (self.swipedCell && self.swipedCell != cell) {
        [self hideActionViewForSwipedCell];
        return NO;
    }

    return YES;
}

- (void)tableViewCellSwipedOpened: (CSTableViewCell *)cell
{
    self.swipedCell = cell;
}

- (void)tableViewCellSwipedClosed: (CSTableViewCell *)cell
{
    self.swipedCell = nil;
}

@end
