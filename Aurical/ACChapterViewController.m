//
//  ACChapterViewController.m
//  Aurical
//
//  Created by Brian Ault on 8/22/14.
//  Copyright (c) 2014 XPR. All rights reserved.
//

#import "ACChapterViewController.h"
#import "ACChapterGroup.h"
#import "ACChapter.h"

@interface ACChapterViewController ()

@end

@implementation ACChapterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.chapterGroup) {
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chapterGroup.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    ACChapter *chapter = [self.chapterGroup chapter:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%d. %@",self.chapterGroup.count,chapter.title];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _selectedChapter = [_chapterGroup chapter:indexPath.row];
}




@end
