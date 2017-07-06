//
//  ACChapter.h
//  Aurical
//
//  Created by Brian Ault on 8/22/14.
//  Copyright (c) 2014 XPR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@interface ACChapter : NSObject
@property (nonatomic) NSString *title;
@property (nonatomic) CMTime time;
@property (nonatomic) CMTime duration;
@property (nonatomic) NSUInteger index;
@end
