//
//  EntryTableViewCell.swift
//  Journal
//
//  Created by Joshua Sharp on 9/16/19.
//  Copyright © 2019 Lambda. All rights reserved.
//

import UIKit

class EntryTableViewCell: UITableViewCell {

    var entry: Entry?{
        didSet{
            updateViews()
        }
    }
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var body: UILabel!
    
    
    private func updateViews(){
        guard let entry = entry else { return }
        title.text = entry.title
        body.text = entry.bodyText
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        //formatter.dateFormat = "
        if let date = entry.timeStamp {
            timeStamp.text = formatter.string(from: date)
        } else {
            timeStamp.text = "Unk"
        }
    }
}
