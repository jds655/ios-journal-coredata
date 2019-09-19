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
    
    init() {
        fetchEntriesFromServer()
    }
    
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
        CoreDataStack.shared.save()
        put(entry: entry)
        return entry
    }
    
    func updateEntry(entry: Entry, with title: String, mood: String, body: String?) {
        entry.title = title
        entry.mood = mood
        entry.bodyText = body
        entry.timeStamp = Date()
        CoreDataStack.shared.save()
        put(entry: entry)
    }
    
    func delete(entry: Entry) {
        CoreDataStack.shared.mainContext.delete(entry)
        CoreDataStack.shared.save()
    }
    
    //MARK: - Firebase code
    
    func put(entry: Entry, completion: @escaping (_ error: Error?) -> Void = { _ in }) {
        let identifier = entry.identifier ?? UUID()
        entry.identifier = identifier
        let requestURL = baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        do {
            guard let entryRepresentation = entry.entryRepresentation else {
                NSLog("Task Representation is nil")
                completion(nil)
                return
            }
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(entryRepresentation)
            print ("HTTP Body: \(String(describing: request.httpBody))")
        } catch {
            NSLog("Error encoding task respresentation: \(error)")
            completion(error)
            return
        }
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                NSLog("Error PUTing entry: \(error)")
                completion(error)
                return
            }
        }.resume()
    }
    
    func fetchEntriesFromServer(completion: @escaping (_ error: Error?) -> Void = { _ in }) {
        let requestURL = baseURL.appendingPathExtension("json")
        URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    print ("HTTP Response: \(response)")
                }
            }
            if let error = error {
                NSLog("Error fetching entries: \(error)")
                completion(error)
            }
            guard let data = data else {
                NSLog("No data returned from entries")
                completion(error)
                return
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let entryRepresentations =  try decoder.decode([String: EntryRepresentation].self, from: data).map({ $0.value })
                self.updateEntries(with: entryRepresentations)
            } catch {
                NSLog("Error decoding: \(error)")
                completion(error)
            }
            }.resume()
            completion(nil)
    }
    
    private func updateEntries(with representations: [EntryRepresentation]) {
        let identifiersToFetch = representations.compactMap({UUID(uuidString: $0.identifier)})
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var entriesToCreate = representationsByID
        let context = CoreDataStack.shared.container.newBackgroundContext()
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        context.performAndWait {
            //Update Local store with Firebase
            do {
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
                CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error fatching entries from persistent store: \(error)")
            }
            //Update Firebase with local only entries
            do {
                fetchRequest.predicate = NSPredicate(value: true)
                let allLocalEntries = try context.fetch(fetchRequest)
                let newLocalEntries = allLocalEntries.filter({!identifiersToFetch.contains($0.identifier!)})
                print ("New local entries to Firebase: \(newLocalEntries.count)")
                for entry in newLocalEntries {
                    put(entry: entry)
                }
            } catch {
                NSLog("Error putting new local entries to Firebase: \(error)")
            }
        }
    }
}
