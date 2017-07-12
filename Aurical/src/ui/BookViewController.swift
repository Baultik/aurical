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
    private var bookCollection = [MPMediaItemCollection]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        //self.detailViewController = (ACPlayerViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
        let query = MPMediaQuery.audiobooks()
        if let collection = query.collections {
            DispatchQueue.global().async {
                for  group in collection {
                    let book: MPMediaItem? = group.representativeItem
                    
                    if let assetURL = book?.value(forProperty: MPMediaItemPropertyAssetURL) {
                        let uasset = AVURLAsset(url:assetURL as! URL, options: nil)
                        var AAC: Bool = false
                        
                        for track: AVAssetTrack in uasset.tracks {
                            for format in track.formatDescriptions {
                                let mediaType: CMMediaType = CMFormatDescriptionGetMediaType(format as! CMFormatDescription)
                                let mediaSubType: FourCharCode = CMFormatDescriptionGetMediaSubType(format as! CMFormatDescription)
                                
                                if mediaType == kCMMediaType_Audio && mediaSubType == UInt32("aac "){
                                        AAC = true
                                }
                            }
                        }
                    }
                    
                    
                    if true {
                        self.bookCollection.append(group)
                    }
                }

                DispatchQueue.main.async(execute: {() -> Void in
                    self.tableView.reloadData()
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
        let mediaItemCollection: MPMediaItemCollection? = bookCollection[indexPath.row] 
        let mediaItem: MPMediaItem? = mediaItemCollection?.representativeItem

            cell.textLabel?.text = mediaItem?.value(forProperty: MPMediaItemPropertyTitle) as? String
            cell.detailTextLabel?.text = mediaItem?.value(forProperty: MPMediaItemPropertyAlbumArtist) as? String
        
        DispatchQueue.global().async {
            if let artwork:MPMediaItemArtwork = mediaItem?.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork {
                
                DispatchQueue.main.async(execute: {() -> Void in
                    cell.imageView?.image = artwork.image(at: (cell.imageView?.bounds.size)!)
                    cell.setNeedsLayout()
                })
            }
        }

        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowParts" {
            //let index = self.tableView.indexPathForSelectedRow?.row
            //let mediaItemCollection = bookCollection[index!]
            
            
//            segue.destination
            
//            MPMediaItemCollection *mediaItemCollection = bookCollection[indexPath.row];
//            ACPartViewController *part = segue.destinationViewController;
//            part.parts = mediaItemCollection;
        }
    }
}
