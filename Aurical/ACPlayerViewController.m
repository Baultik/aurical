//
//  ACDetailViewController.m
//  Aurical
//
//  Created by Brian Ault on 8/21/14.
//  Copyright (c) 2014 XPR. All rights reserved.
//

#import "ACPlayerViewController.h"
#import "ACChapterGroup.h"
#import "ACChapter.h"
#import "ACChapterViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

static void *PlayerStatusObserverContext = &PlayerStatusObserverContext;

@interface ACPlayerViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (nonatomic,strong)ACChapterGroup *chapterGroup;
@property (nonatomic,strong)AVPlayer *player;
@property (nonatomic,readwrite,getter = isSeeking)BOOL seeking;
@property (strong, nonatomic) id playerTimeObserver;
@end

@implementation ACPlayerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.audioBook) {
        NSURL *url = [self.audioBook valueForProperty: MPMediaItemPropertyAssetURL];
        AVURLAsset *uasset = [AVURLAsset URLAssetWithURL: url options:nil];
        if (uasset) {
            self.chapterGroup = [ACChapterGroup chapterGroupFromAsset:uasset];
            
            self.bookTitleLabel.text = [self.audioBook valueForProperty:MPMediaItemPropertyTitle];
            self.bookAuthorLabel.text = [self.audioBook valueForProperty:MPMediaItemPropertyArtist];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                MPMediaItemArtwork *artwork = [self.audioBook valueForProperty:MPMediaItemPropertyArtwork];
                if (artwork != nil) {
                    UIImage *image = [artwork imageWithSize:self.bookImageView.bounds.size];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.bookImageView.image = image;
                    });
                }
            });
            
            NSNumber *number = [self.audioBook valueForKeyPath:MPMediaItemPropertyBookmarkTime];
            NSTimeInterval bookmark = [number doubleValue];
            CMTime bookmarkTime = CMTimeMakeWithSeconds((Float64)bookmark, 1);
            [self.chapterGroup chapterFromTime:bookmarkTime];
            
            float value = [self sliderValueForTime:bookmarkTime];
            self.bookSlider.value = value;
            
            [self updateChapterInfo];
        }
        
        [self prepareAsset:self.audioBook];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self isMovingFromParentViewController] && self.player) {
        [self.player removeObserver:self forKeyPath:@"status" context:PlayerStatusObserverContext];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (PlayerStatusObserverContext == context) {
		id newValue = change[NSKeyValueChangeNewKey];
		if (newValue && [newValue isKindOfClass:[NSNumber class]]) {
			if (AVPlayerStatusReadyToPlay == [newValue integerValue]) {
                //m_pTimeCurrentLabel.text = @"0:00";
                //m_pTrackSlider.value = 0.0f;
                
                NSNumber *number = [self.audioBook valueForKeyPath:MPMediaItemPropertyBookmarkTime];
                NSTimeInterval bookmark = [number doubleValue];
                [self seekToTime:CMTimeMakeWithSeconds((Float64)bookmark, 1)];
                
                if (self.playerTimeObserver == nil) {
                    __weak ACPlayerViewController *weakSelf = self;
                    self.playerTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                        // Update current time indicators.
                        //float seconds = round(CMTimeGetSeconds(time));
                        //CMTime duration = self.player.currentItem.duration;
                        //m_pTimeCurrentLabel.text = [self formatDuration:seconds];
                        if (!weakSelf.isSeeking)
                            weakSelf.bookSlider.value = [weakSelf sliderValueForTime:time];
                    }];
				}
                [self playerPlay];
			}
		}
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (float)sliderValueForTime:(CMTime)time
{
    ACChapter *chapter = self.chapterGroup.currentChapter;
    float value = CMTimeGetSeconds(CMTimeSubtract(time, chapter.time)) / CMTimeGetSeconds(chapter.duration);
    return value;
}

#pragma mark - Player control

- (void)playerPlay
{
    if (self.player.rate == 0.0f) {
		// Play from beginning when playhead is at end.
		if (CMTIME_COMPARE_INLINE(self.player.currentItem.currentTime, >=, self.player.currentItem.duration)) {
			[self.player.currentItem seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
		}
		
		// Start playback.
		self.player.rate = 1.0f;
	}
	else {
		// Stop playback.
		self.player.rate = 0.0f;
	}
}

- (void)seekToTime:(CMTime)time
{
    self.seeking = YES;
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {
            self.seeking = NO;
        }
    }];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Actions

- (IBAction)sliderScrubbed:(UISlider *)sender {
}

- (IBAction)doPrev:(UIButton *)sender
{
    
}

- (IBAction)doNext:(UIButton *)sender
{
    
}

- (IBAction)doPlay:(UIButton *)sender
{
    [self playerPlay];
}

- (void)updateChapterInfo
{
    ACChapter *chapter = self.chapterGroup.currentChapter;
    self.title = chapter.title;
    self.bookChapterLabel.text = [NSString stringWithFormat:@"Chapter %d of %d",chapter.index,self.chapterGroup.count];
}

- (int)prepareAsset:(MPMediaItem*)track
{
    self.player.rate = 0.0f;
    
	NSURL *url = [track valueForProperty: MPMediaItemPropertyAssetURL];
    AVURLAsset *uasset = [AVURLAsset URLAssetWithURL: url options:nil];
/*
	if (uasset.hasProtectedContent) {
		NSLog(@"DRM");
		return -1;
	}
*/
    NSNumber *cloud = [track valueForProperty:MPMediaItemPropertyIsCloudItem];
    if ([cloud boolValue]) {
        NSLog(@"Cloud item ");
        return -2;
    }
    
    if (self.player == nil) {
        self.player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:uasset]];
        [self.player addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:PlayerStatusObserverContext];
    }
    else {
        [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithAsset:uasset]];
    }
    
    [self updateChapterInfo];
    
	return 0;
}

#pragma mark - Storyboard

- (IBAction)unwind:(UIStoryboardSegue *)segue
{
    if ([[segue identifier] isEqualToString:@"ShowChapters"]) {
        ACChapterViewController *chapter = segue.destinationViewController;
        if (chapter.selectedChapter != nil) {
            [self.chapterGroup setChapter:chapter.selectedChapter.index];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowChapters"]) {
        ACChapterViewController *chapter = segue.destinationViewController;
        chapter.chapterGroup = self.chapterGroup;
    }
}

@end
