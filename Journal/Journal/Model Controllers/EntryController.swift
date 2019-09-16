//
//  EntryController.swift
//  Journal
//
//  Created by Joshua Sharp on 9/16/19.
//  Copyright © 2019 Lambda. All rights reserved.
//

import Foundation
import CoreData

protocol EntryDataDelegate {
    func updateEntry (entry: Entry, with title: String, body: String?)
    func createEntry (with title: String, body: String?)
}

class EntryController {
    
    var entries: [Entry] {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        
        do {
            let entries = try CoreDataStack.shared.mainContext.fetch(fetchRequest)
            return entries
        } catch {
            NSLog("Error fetching tasks: \(error)")
            return []
        }
    }
    
    @discardableResult func createEntry(with title: String, body: String?) -> Entry {
        let entry = Entry(title: title, bodyText: body, context: CoreDataStack.shared.mainContext)
        
        CoreDataStack.shared.saveToPersistentStore()
        return entry
    }
    
    func updateEntry(entry: Entry, with title: String, body: String?) {
        entry.title = title
        entry.bodyText = body
        entry.timeStamp = Date()
        
        CoreDataStack.shared.saveToPersistentStore()
    }
    
    func delete(entry: Entry) {
        CoreDataStack.shared.mainContext.delete(entry)
        CoreDataStack.shared.saveToPersistentStore()
    }
}
