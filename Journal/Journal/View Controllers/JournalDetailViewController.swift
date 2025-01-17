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
        navigationController?.popViewController(animated: true)
    }
    
    private func updateViews() {
        view.backgroundColor = UIColor.black
        titleTF.layer.cornerRadius = 5
        titleTF.clipsToBounds = true
        bodyTV.layer.cornerRadius = 5
        bodyTV.clipsToBounds = true
        if let entry = entry {
            let entryTitle = entry.title ?? ""
            title = "Editing - \(entryTitle)"
            titleTF.text = entry.title
            bodyTV.text = entry.bodyText
        } else {
            title = "Create Entry..."
        }
    }

}
