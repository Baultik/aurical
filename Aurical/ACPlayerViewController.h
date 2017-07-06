//
//  ACDetailViewController.h
//  Aurical
//
//  Created by Brian Ault on 8/21/14.
//  Copyright (c) 2014 XPR. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MPMediaItem;

@interface ACPlayerViewController : UIViewController <UISplitViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *bookChapterLabel;
@property (weak, nonatomic) IBOutlet UILabel *bookAuthorLabel;
@property (weak, nonatomic) IBOutlet UILabel *bookTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bookImageView;
@property (weak, nonatomic) IBOutlet UISlider *bookSlider;
@property (nonatomic,strong)MPMediaItem *audioBook;

- (IBAction)sliderScrubbed:(UISlider *)sender;
- (IBAction)doPrev:(UIButton *)sender;
- (IBAction)doNext:(UIButton *)sender;
- (IBAction)doPlay:(UIButton *)sender;

@end
