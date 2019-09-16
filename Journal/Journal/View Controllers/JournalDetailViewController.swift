//
//  JournalDetailViewController.swift
//  Journal
//
//  Created by Joshua Sharp on 9/16/19.
//  Copyright © 2019 Lambda. All rights reserved.
//

import UIKit

class JournalDetailViewController: UIViewController {

    var entry: Entry?
    var delegate: EntryDataDelegate?
    
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var bodyTV: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        guard let title = titleTF.text, !title.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Please enter a title.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true)
            return
        }
        if let entry = entry {
            delegate?.updateEntry(entry: entry, with: title, body: bodyTV.text)
        } else {
            delegate?.createEntry(with: title, body: bodyTV.text)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    private func updateViews() {
        if let entry = entry {
            title = "Editing \(String(describing: entry.title))"
            titleTF.text = entry.title
            bodyTV.text = entry.bodyText
        } else {
            title = "Create Entry..."
        }
    }

}
