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
    func updateEntry (entry: Entry, with title: String, mood: String, body: String?)
    func createEntry (with title: String, mood: String, body: String?)
}

//enum Mood: String {
//    case sad = "☹️"
//    case nuetrasl = "😐"
//    case happy = "🙂"
//}

class EntryController {
    
//    var entries: [Entry] {
//        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//
//        do {
//            let entries = try CoreDataStack.shared.mainContext.fetch(fetchRequest)
//            return entries
//        } catch {
//            NSLog("Error fetching tasks: \(error)")
//            return []
//        }
//    }
    let baseURL = URL(string: "https://journal-d8910.firebaseio.com/")!
    
    @discardableResult func createEntry(with title: String, mood: String, body: String?) -> Entry {
        let entry = Entry(identifier: UUID(), title: title, mood: mood, bodyText: body, context: CoreDataStack.shared.mainContext)
        CoreDataStack.shared.saveToPersistentStore()
        put(entry: entry)
        return entry
    }
    
    func updateEntry(entry: Entry, with title: String, mood: String, body: String?) {
        entry.title = title
        entry.mood = mood
        entry.bodyText = body
        entry.timeStamp = Date()
        CoreDataStack.shared.saveToPersistentStore()
        put(entry: entry)
    }
    
    func delete(entry: Entry) {
        CoreDataStack.shared.mainContext.delete(entry)
        CoreDataStack.shared.saveToPersistentStore()
    }
    
    //MARK: - Firebase code
    
    func put(entry: Entry, completion: @escaping () -> Void = { }) {
        let identifier = entry.identifier ?? UUID()
        entry.identifier = identifier
        let requestURL = baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        do {
            guard let entryRepresentation = entry.entryRepresentation else {
                NSLog("Task Representation is nil")
                completion()
                return
            }
            request.httpBody = try JSONEncoder().encode(entryRepresentation)
        } catch {
            NSLog("Error encoding task respresentation: \(error)")
            completion()
            return
        }
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                NSLog("Error PUTing entry: \(error)")
                completion()
                return
            }
        }
    }
    
    func fetchEntriesFromServer(completion: @escaping () -> Void = { }) {
        let requestURL = baseURL.appendingPathExtension("json")
        URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            if let error = error {
                NSLog("Error fetching entries: \(error)")
                completion()
            }
            guard let data = data else {
                NSLog("No data returned from entries")
                completion()
                return
            }
            let decoder = JSONDecoder()
            do {
                let entryRepresentations =  try decoder.decode([String: EntryRepresentation].self, from: data).map({ $0.value })
                self.updateEntries(with: entryRepresentations)
            } catch {
                NSLog("Error decoding: \(error)")
            }
            }.resume()
    }
    
    private func updateEntries(with representations: [EntryRepresentation]) {
        let identifiersToFetch = representations.compactMap({UUID(uuidString: $0.identifier)})
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var entriesToCreate = representationsByID
        do {
            let context = CoreDataStack.shared.mainContext
            let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
            let existingEntries = try context.fetch(fetchRequest)
            for entry in existingEntries {
                guard let identifier = entry.identifier,
                    let representation = representationsByID[identifier] else { continue }
                entry.title = representation.title
                entry.bodyText = representation.bodyText
                entry.mood = representation.mood
                entry.timeStamp = representation.timeStamp
                entriesToCreate.removeValue(forKey: identifier)
            }
            for representation in entriesToCreate.values {
                Entry(entryRepresentaion: representation, context: context)
            }
            CoreDataStack.shared.saveToPersistentStore()
        } catch {
            NSLog("Error fatching tasks from persistent store: \(error)")
        }
    }
}
