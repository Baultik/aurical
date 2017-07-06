//
//  ACChapterViewController.h
//  Aurical
//
//  Created by Brian Ault on 8/22/14.
//  Copyright (c) 2014 XPR. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ACChapterGroup;
@class ACChapter;

@interface ACChapterViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)ACChapterGroup *chapterGroup;
@property (nonatomic,strong,readonly)ACChapter *selectedChapter;
@end
