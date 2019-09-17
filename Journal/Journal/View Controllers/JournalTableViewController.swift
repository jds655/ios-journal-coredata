//
//  JournalTableViewController.swift
//  Journal
//
//  Created by Joshua Sharp on 9/16/19.
//  Copyright © 2019 Lambda. All rights reserved.
//

import UIKit

@IBDesignable
class JournalTableViewController: UITableViewController {

    let entryController = EntryController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.backgroundColor = .black
        tableView.tintColor = .white
        tableView.backgroundView?.backgroundColor = .black
        tableView.separatorColor = .white
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return entryController.entries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EntryCell", for: indexPath) as? EntryTableViewCell else { return UITableViewCell()}
        cell.entry = entryController.entries[indexPath.row]
        cell.heightAnchor.constraint(equalToConstant: 100).isActive = true
        cell.body.layer.cornerRadius = 5
        cell.body.clipsToBounds = true
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            entryController.delete(entry: entryController.entries[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? JournalDetailViewController else { return }
        vc.delegate = self
        switch segue.identifier {
        case "DetailSegue":
            if let index = tableView.indexPathForSelectedRow?.row {
                vc.entry = entryController.entries[index]
            }
        case "AddSegue":
            break
        default:
            break
        }
    }
}

extension JournalTableViewController:EntryDataDelegate {
    func updateEntry(entry: Entry, with title: String, body: String?) {
        entryController.updateEntry(entry: entry, with: title, body: body)
        tableView.reloadData()
    }
    
    func createEntry(with title: String, body: String?) {
        entryController.createEntry(with: title, body: body)
        tableView.reloadData()
    }
    
    
}
