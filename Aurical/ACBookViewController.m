//
//  ACMasterViewController.m
//  Aurical
//
//  Created by Brian Ault on 8/21/14.
//  Copyright (c) 2014 XPR. All rights reserved.
//

#import "ACBookViewController.h"
#import "ACPartViewController.h"
#import "ACChapter.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface ACBookViewController ()
{
    NSMutableArray *bookCollection;
}
@end

@implementation ACBookViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //self.detailViewController = (ACPlayerViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    MPMediaQuery *query = [MPMediaQuery audiobooksQuery];
    bookCollection = [NSMutableArray arrayWithCapacity:query.collections.count];
    NSArray *collection = query.collections;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        //Ensure audiobooks is m4b with aac inside
        for (MPMediaItemCollection *group in collection) {
            MPMediaItem *book = [group representativeItem];
            NSURL *url = [book valueForProperty: MPMediaItemPropertyAssetURL];
            AVURLAsset *uasset = [AVURLAsset URLAssetWithURL: url options:nil];
            BOOL AAC = NO;
            
            for (AVAssetTrack *track in uasset.tracks) {
                NSArray *formats = track.formatDescriptions;
                for (int i = 0; i< formats.count; i++) {
                    CMFormatDescriptionRef format = (__bridge CMFormatDescriptionRef)[formats objectAtIndex:i];
                    CMMediaType mediaType = CMFormatDescriptionGetMediaType(format);
                    FourCharCode mediaSubType = CMFormatDescriptionGetMediaSubType(format);
                    
                    if (mediaType == kCMMediaType_Audio) {
                        if (mediaSubType == 'aac ') {
                            AAC = YES;
                        }
                    }
                }
            }
            if (YES) {
                [bookCollection addObject:group];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return bookCollection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    MPMediaItemCollection *mediaItemCollection = bookCollection[indexPath.row];
    MPMediaItem *mediaItem = [mediaItemCollection representativeItem];
    NSString *artist = [mediaItem valueForProperty:MPMediaItemPropertyAlbumArtist];
    NSString *title = [mediaItem valueForProperty:MPMediaItemPropertyTitle];
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = artist;
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowParts"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        MPMediaItemCollection *mediaItemCollection = bookCollection[indexPath.row];
        ACPartViewController *part = segue.destinationViewController;
        part.parts = mediaItemCollection;
    }
}

@end
