//
//  ACPartViewController.m
//  Aurical
//
//  Created by Brian Ault on 8/22/14.
//  Copyright (c) 2014 XPR. All rights reserved.
//

#import "ACPartViewController.h"
#import "ACPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ACPartViewController ()

@end

@implementation ACPartViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.parts) {
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.parts.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    MPMediaItem *mediaItem = self.parts.items[indexPath.row];
    
    cell.textLabel.text = [mediaItem valueForProperty:MPMediaItemPropertyTitle];
    cell.detailTextLabel.text = [mediaItem valueForProperty:MPMediaItemPropertyArtist];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        MPMediaItemArtwork *artwork = [mediaItem valueForProperty:MPMediaItemPropertyArtwork];
        if (artwork != nil) {
            UIImage *image = [artwork imageWithSize:cell.imageView.bounds.size];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.imageView.image = image;
                [cell setNeedsLayout];
            });
        }
    });
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowPlayer"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        MPMediaItem *mediaItem = self.parts.items[indexPath.row];
        ACPlayerViewController *player = segue.destinationViewController;
        player.audioBook = mediaItem;
    }
    
}

@end
