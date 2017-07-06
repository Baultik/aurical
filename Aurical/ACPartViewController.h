//
//  ACPartViewController.h
//  Aurical
//
//  Created by Brian Ault on 8/22/14.
//  Copyright (c) 2014 XPR. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MPMediaItemCollection;

@interface ACPartViewController : UITableViewController
@property (nonatomic,strong)MPMediaItemCollection *parts;
@end
