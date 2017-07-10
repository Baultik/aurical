//
//  ChapterGroup.swift
//  Aurical
//
//  Created by Brian Ault on 7/6/17.
//  Copyright © 2017 XPR. All rights reserved.
//

import AVFoundation
import CoreMedia
import Foundation
import MediaPlayer

class ChapterGroup: NSObject {
    var count:Int {
        if let count = chapters?.count {
            return count
        }
        return 0
    }
    
    var asset: AVAsset {
        didSet {
            let languages: [String] = self.languages(for: asset)
            let groups = asset.chapterMetadataGroups(bestMatchingPreferredLanguages: languages)
            chapters = parseChapters(from: groups)
            currentChapter = chapters?[0]
        }
    }
//    private var groups: [AVTimedMetadataGroup]?
    private var chapters: [Chapter]?
    private(set) var currentChapter: Chapter?
    
    init(audiobookAsset:AVAsset) {
        asset = audiobookAsset
        
    }
    
    func chapter(at time: CMTime) -> Chapter? {
        var result : Chapter?
        if let chs = chapters {
            for chapter: Chapter in chs {
                if CMTimeCompare(CMTimeAdd(chapter.time, chapter.duration), time) > 0 {
                    result = chapter
                    break
                }
            }
        }
        
        return result
    }
    
    func chapter(_ index: Int) -> Chapter? {
        var result:Chapter?
        if  let valid = chapters?.indices.contains(index) {
            if valid {
                result = chapters?[index]
            }
        }
        
        return result
    }
    
    func setChapter(_ index: Int) -> Bool {
        if  let valid = chapters?.indices.contains(index) {
            if valid {
                currentChapter = chapters?[index]
                return true
            }
        }
        return false
    }
    
    func nextChapter() -> Bool {
        var next = 0
        if let current = currentChapter?.index {
            next = current + 1
        }
        
        return setChapter(next)
    }
    
    func previousChapter() -> Bool {
        var prev = 0
        if let current = currentChapter?.index {
            prev = current - 1
        }
        
        return setChapter(prev)
    }
    
    // MARK: - Chapter
    private func parseChapters(from chapterGroup: [AVTimedMetadataGroup]) -> [Chapter]? {
        let formats: [String] = asset.availableMetadataFormats
        var result :[Chapter]?
        for format in formats {
            if (format == "org.mp4ra") {
                result = parseMP4Chapters(from: chapterGroup)
            }
        }
        return result
    }
    
    private func parseMP4Chapters(from chapterGroup: [AVTimedMetadataGroup]) -> [Chapter] {
        var result = [Chapter]()
        for i in 0..<chapterGroup.count {
            let group  = chapterGroup[i]
            let items = AVMetadataItem.metadataItems(from: group.items, withKey: "title", keySpace: nil)
            let item = items[0]
            let chapter = Chapter()
            chapter.title = item.stringValue
            chapter.time = item.time
            chapter.duration = item.duration
            chapter.index = i
            result.append(chapter)
        }
        return result
    }
    
    private func languages(for asset: AVAsset) -> [String] {
        var languages = NSLocale.preferredLanguages
        let locales = asset.availableChapterLocales
        for locale in locales {
            languages.append(locale.identifier)
        }
        return languages
    }
    
    func image(from group: AVTimedMetadataGroup) -> UIImage {
        let item: AVMetadataItem? = itemsFromArray(item: group.items, withKey: "artwork")[0]
        return UIImage(data: (item?.dataValue)!)!
    }
    
    func url(from group: AVTimedMetadataGroup, for title: String) -> String? {
        let items: [AVMetadataItem] = itemsFromArray(item: group.items, withKey: "title")
        var href: String?
        for item in items {
            if item.stringValue == title && (item.extraAttributes != nil) {
                if let extra = item.extraAttributes?["HREF"] {
                    href = extra as? String
                    break
                }
            }
        }
        return href;
    }
    
    func itemsFromArray(item:[AVMetadataItem], withKey key:String) -> [AVMetadataItem] {
        return AVMetadataItem.metadataItems(from: item, withKey: key, keySpace: nil)
    }
}
