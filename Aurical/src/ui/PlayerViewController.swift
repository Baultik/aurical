//
//  PlayerViewController.swift
//  Aurical
//
//  Created by Brian Ault on 7/13/17.
//  Copyright © 2017 XPR. All rights reserved.
//

import UIKit
import MediaPlayer
import CoreMedia

class PlayerViewController: UIViewController {
    var audiobook:MPMediaItem?
    var chapterGroup:ChapterGroup?
    var player:AVPlayer?
    var seeking:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url:NSURL = audiobook?.value(forProperty: MPMediaItemPropertyAssetURL) as? NSURL {
            let uasset = AVURLAsset(url: url as URL)
            chapterGroup = ChapterGroup(audiobookAsset: uasset)
            
//            self.bookTitleLabel.text = [self.audioBook valueForProperty:MPMediaItemPropertyTitle];
//            self.bookAuthorLabel.text = [self.audioBook valueForProperty:MPMediaItemPropertyArtist];
            DispatchQueue.global().async {
                if let artwork = self.audiobook?.value(forProperty: MPMediaItemPropertyArtwork) {
                    DispatchQueue.main.async {
//                        bookImageView.image = artwork.image(at:bookImageView.bounds.size)
                    }
                }
            }
            
            
            if let bookmark:NSNumber = audiobook?.value(forKeyPath: MPMediaItemPropertyBookmarkTime) as? NSNumber {
                
                var bookmarkTime = CMTimeMake(bookmark.int64Value, 1)
                var value = sliderValue(at: bookmarkTime)
                
                updateChapterInfo()
            }
            
        }
        

                
//                NSNumber *number = [self.audioBook valueForKeyPath:MPMediaItemPropertyBookmarkTime];
//                NSTimeInterval bookmark = [number doubleValue];
//                CMTime bookmarkTime = CMTimeMakeWithSeconds((Float64)bookmark, 1);
//                [self.chapterGroup chapterFromTime:bookmarkTime];
            
//                float value = [self sliderValueForTime:bookmarkTime];
//                self.bookSlider.value = value;
            
//                [self updateChapterInfo];
        
            
//            [self prepareAsset:self.audioBook];
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingToParentViewController && player != nil {
            
        }
        
        
//        if ([self isMovingFromParentViewController] && self.player) {
//            [self.player removeObserver:self forKeyPath:@"status" context:PlayerStatusObserverContext];
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateChapterInfo() {
        if let chapter = chapterGroup?.currentChapter {
            
        }

//        self.title = chapter.title;
//        self.bookChapterLabel.text = [NSString stringWithFormat:@"Chapter %d of %d",chapter.index,self.chapterGroup.count];
    }
    
    func sliderValue(at time:CMTime) -> Float64 {
        var value:Float64 = 0
        if let chapter = chapterGroup?.currentChapter {
            value = CMTimeGetSeconds(CMTimeSubtract(time, chapter.time))
        }
        
        return value;
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
