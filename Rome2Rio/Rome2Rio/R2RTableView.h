//
//  R2RTableView.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 29/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol R2RTableViewDelegate;

@interface R2RTableView : UITableView

@end


@protocol R2RTableViewDelegate <UITableViewDelegate>

@optional

- (void) reloadDataDidFinish;

@end
