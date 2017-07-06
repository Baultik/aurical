//
//  ACChapterGroup.m
//  Aurical
//
//  Created by Brian Ault on 8/22/14.
//  Copyright (c) 2014 XPR. All rights reserved.
//

#import "ACChapterGroup.h"
#import "ACChapter.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface ACChapterGroup ()
@property (nonatomic,strong)AVAsset *asset;
@property (nonatomic,strong)NSArray *groups;
@property (nonatomic,strong)NSMutableArray *chapters;
@end

@implementation ACChapterGroup

+ (ACChapterGroup*)chapterGroupFromAsset:(AVAsset*)asset
{
    return [[ACChapterGroup alloc]initFromAsset:asset];
}

- (ACChapterGroup*)initFromAsset:(AVAsset*)asset
{
    self = [super init];
    if (self) {
        _asset = asset;
        
        NSArray *languages = [self languagesForAsset:asset];
        

        for (AVAssetTrack *track in asset.tracks) {
            NSArray *meta = track.availableMetadataFormats;
        }
        
        for (AVAssetTrackGroup *group in asset.trackGroups) {
            
        }
        
        _groups = [asset chapterMetadataGroupsBestMatchingPreferredLanguages:languages];
        _count = _groups.count;
        
        [self parseChaptersFromAsset:_asset];
    }
    return self;
}

- (ACChapter*)chapterFromTime:(CMTime)time
{
    for (ACChapter *chapter in _chapters) {
        if (CMTimeCompare(CMTimeAdd(chapter.time, chapter.duration), time) > 0) {
            _currentChapter = chapter;
            return chapter;
        }
    }
    return nil;
}

- (ACChapter*)chapter:(NSUInteger)index
{
    if (index >= _chapters.count) return nil;
    return _chapters[index];
}

- (BOOL)setChapter:(NSUInteger)index
{
    if (index >= _chapters.count) return NO;
    _currentChapter = _chapters[index];
    return YES;
}

- (BOOL)nextChapter
{
    NSUInteger current = _currentChapter.index;
    if (++current < _chapters.count) {
        return [self setChapter:current];
    }
    return NO;
}

- (BOOL)previousChapter
{
    NSUInteger current = _currentChapter.index;
    NSInteger prev = current - 1;
    if (prev < 0) {
        return NO;
    }
    return [self setChapter:--current];
}

#pragma mark - Chapter

- (void)parseChaptersFromAsset:(AVAsset *)asset {
    NSArray *formats = asset.availableMetadataFormats;
    
    NSArray *result = nil;
    for (NSString *format in formats) {
        if ([format isEqualToString:@"org.mp4ra"]) {
            result = [self parseMP4ChaptersFromAsset:asset];
        }
    }
}

- (NSArray *)parseMP4ChaptersFromAsset:(AVAsset *)asset {
    _chapters = [[NSMutableArray alloc] initWithCapacity:_groups.count];
    
    for (NSUInteger i = 0; i < _groups.count; i++) {
        AVTimedMetadataGroup *group = _groups[i];
        NSArray *items = [AVMetadataItem metadataItemsFromArray:group.items withKey:@"title" keySpace:nil];
        AVMetadataItem *item = items[0];
        
        ACChapter *chapter = [[ACChapter alloc]init];
        chapter.title = item.stringValue;
        chapter.time = item.time;
        chapter.duration = item.duration;
        chapter.index = i;
        [_chapters addObject:chapter];
    }
    
    _currentChapter = _chapters.count > 0 ? _chapters[0] : nil;
    
    return _chapters;
}

- (NSArray *)languagesForAsset:(AVAsset *)asset {
    NSArray *preferred = [NSLocale preferredLanguages];
    NSMutableArray *languages = [NSMutableArray arrayWithArray:preferred];
    NSArray *locales = [asset availableChapterLocales];
    
    for (NSLocale *locale in locales) {
        [languages addObject:[locale localeIdentifier]];
    }
    
    return languages;
}

- (UIImage *)imageFromGroup:(AVTimedMetadataGroup *)group {
    AVMetadataItem *item = [self itemsFromArray:group.items withKey:@"artwork"][0];
    return [UIImage imageWithData:item.dataValue];
}

- (NSString *)urlFromGroup:(AVTimedMetadataGroup *)group forTitle:(NSString *)title {
    NSArray *items = [self itemsFromArray:group.items withKey:@"title"];
    NSString *href = nil;
    for (AVMetadataItem *item in items) {
        if ([item.stringValue isEqualToString:title] && item.extraAttributes) {
            href = item.extraAttributes[@"HREF"];
            if (href) break;
        }
    }
    return href;
}

- (NSArray *)itemsFromArray:(NSArray *)items withKey:(NSString *)key {
    return [AVMetadataItem metadataItemsFromArray:items withKey:key keySpace:nil];
}

@end
