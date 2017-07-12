//
//  PartViewController.swift
//  Aurical
//
//  Created by Brian Ault on 7/12/17.
//  Copyright © 2017 XPR. All rights reserved.
//

import UIKit
import MediaPlayer

class PartViewController: UITableViewController {
    var parts: MPMediaItemCollection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if parts != nil {
            tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let part = parts {
            return part.items.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        if let mediaItem = parts?.items[indexPath.row] {
            cell.textLabel?.text = mediaItem.value(forProperty: MPMediaItemPropertyTitle) as? String
            cell.detailTextLabel?.text = mediaItem.value(forProperty: MPMediaItemPropertyArtist) as? String
            
            DispatchQueue.global().async {
                if let artwork = mediaItem.value(forProperty:MPMediaItemPropertyArtwork) as? MPMediaItemArtwork {
                    DispatchQueue.main.async {
                        cell.imageView?.image = artwork.image(at:(cell.imageView?.bounds.size)!)
                        cell.setNeedsLayout()
                    }
                }
            }
        }

        return cell
    }
 
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowPlayer") {
//            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//            MPMediaItem *mediaItem = self.parts.items[indexPath.row];
//            ACPlayerViewController *player = segue.destinationViewController;
//            player.audioBook = mediaItem;
        }
    }

}
