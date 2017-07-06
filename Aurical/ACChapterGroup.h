//
//  ACChapterGroup.h
//  Aurical
//
//  Created by Brian Ault on 8/22/14.
//  Copyright (c) 2014 XPR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@class AVAsset;
@class ACChapter;

struct CMTime;

@interface ACChapterGroup : NSObject

@property (nonatomic,readonly) NSUInteger count;
@property (nonatomic,strong,readonly)ACChapter *currentChapter;

+ (ACChapterGroup*)chapterGroupFromAsset:(AVAsset*)asset;
- (ACChapter*)chapterFromTime:(CMTime)time;
- (ACChapter*)chapter:(NSUInteger)index;
- (BOOL)setChapter:(NSUInteger)index;
- (BOOL)nextChapter;
- (BOOL)previousChapter;
@end
