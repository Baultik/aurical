//
//  ChapterViewController.swift
//  Aurical
//
//  Created by Brian Ault on 7/12/17.
//  Copyright © 2017 XPR. All rights reserved.
//

import UIKit

class ChapterViewController: UITableViewController {
    
    var chapterGroup:ChapterGroup? {
        didSet {
            if (tableView != nil) {
                tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (chapterGroup != nil) {
            tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let group = chapterGroup {
            return group.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        var chapter = chapterGroup?.chapter(indexPath.row)
        cell.textLabel?.text = "\(chapterGroup.count). \(chapter?.title)"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var selectedChapter = chapterGroup?.chapter(indexPath.row)
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
