//
//  BookViewController.swift
//  Aurical
//
//  Created by Brian Ault on 7/5/17.
//  Copyright © 2017 XPR. All rights reserved.
//

import AVFoundation
import MediaPlayer
import UIKit

class BookViewController: UITableViewController {
    private var bookCollection = [Any]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        //self.detailViewController = (ACPlayerViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
        let query = MPMediaQuery.audiobooks()
        if let collection = query.collections {
            let queue = DispatchQueue(label: "CollectionQueue")
            queue.async {
                for  group in collection {
                    let book: MPMediaItem? = group.representativeItem
                    let url: URL? = book?.value(forProperty: MPMediaItemPropertyAssetURL) as! URL
                    let uasset = AVURLAsset(url:url!, options: nil)
                    var AAC: Bool = false
                    for track: AVAssetTrack in uasset.tracks {
                        let formats: [Any] = track.formatDescriptions
                        for i in 0..<formats.count {
                            let format: CMFormatDescription? = (formats[i] as? CMFormatDescription)
                            let mediaType: CMMediaType = CMFormatDescriptionGetMediaType(format!)
                            let mediaSubType: FourCharCode = CMFormatDescriptionGetMediaSubType(format!)
                            if mediaType == kCMMediaType_Audio {
                                if mediaSubType == c {
                                    AAC = true
                                }
                            }
                        }
                    }
                    if true {
                        bookCollection.append(group)
                    }
                }

                DispatchQueue.main.async(execute: {() -> Void in
                    tableView.reloadData()
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return bookCollection.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let mediaItemCollection: MPMediaItemCollection? = bookCollection[indexPath.row] as! MPMediaItemCollection
        let mediaItem: MPMediaItem? = mediaItemCollection?.representativeItem
            let artist: String? = mediaItem?.value(forProperty: MPMediaItemPropertyAlbumArtist)
            let title: String? = mediaItem?.value(forProperty: MPMediaItemPropertyTitle)
            cell?.textLabel?.text = title
            cell?.detailTextLabel?.text = artist
            DispatchQueue.global(qos: .default).async(execute: {() -> Void in
                let artwork: MPMediaItemArtwork? = mediaItem?.value(forProperty: MPMediaItemPropertyArtwork)
                if artwork != nil {
                    let image: UIImage? = artwork?.image(withSize: cell?.imageView?.bounds?.size)
                    DispatchQueue.main.async(execute: {() -> Void in
                        cell?.imageView?.image = image
                        cell?.setNeedsLayout()
                    })
                }
            })
            return cell!

        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowParts" {
            tableView.indexPathForSelectedRow
            
//            segue.destination
            
//            MPMediaItemCollection *mediaItemCollection = bookCollection[indexPath.row];
//            ACPartViewController *part = segue.destinationViewController;
//            part.parts = mediaItemCollection;
        }
    }
}
