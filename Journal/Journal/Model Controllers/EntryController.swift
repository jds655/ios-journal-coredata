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

class EntryController {
    
    init() {
        fetchEntriesFromServer()
    }
    
    func sync(completion: @escaping () -> Void = {}) {
        fetchEntriesFromServer()
        completion()
    }
    
    @discardableResult func create(with title: String, mood: String, body: String?) -> Entry {
        let entry = Entry(identifier: UUID(), title: title, mood: mood, bodyText: body, context: CoreDataStack.shared.mainContext)
        CoreDataStack.shared.save()
        put(representation: entry.entryRepresentation)
        return entry
    }
    
    func update(entry: Entry, with title: String, mood: String, body: String?) {
        entry.title = title
        entry.mood = mood
        entry.bodyText = body
        entry.timeStamp = Date()
        CoreDataStack.shared.save()
        put(representation: entry.entryRepresentation)
    }
    
    func delete(entry: Entry) {
        CoreDataStack.shared.mainContext.delete(entry)
        CoreDataStack.shared.save()
        //Implement delete from Firebase?
    }
    
    //MARK: - Firebase code
    
    func put(representation: EntryRepresentation?, completion: @escaping (_ error: Error?) -> Void = { _ in }) {
        guard let representation = representation else {
            NSLog("Task Representation is nil for put function.")
            completion(AppError.objectToRepFailed)
            return
            }
        let requestURL = baseURL.appendingPathComponent(representation.identifier).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(representation)
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
                    completion(NetworkError.responseError)
                }
            }
            if let error = error {
                NSLog("Error fetching entries: \(error)")
                completion(NetworkError.responseError)
            }
            guard let data = data else {
                NSLog("No data returned from entries")
                completion(NetworkError.noData)
                return
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let entryRepresentations =  try decoder.decode([String: EntryRepresentation].self, from: data).map({ $0.value })
                self.updateEntries(with: entryRepresentations)
            } catch {
                NSLog("Error decoding: \(error)")
                completion(NetworkError.noDecode)
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
                        var representation = representationsByID[identifier] else { continue }
                    //Update FROM Firebase if it's newer
                    if let timestamp = entry.timeStamp, timestamp < representation.timeStamp {
                        entry.title = representation.title
                        entry.bodyText = representation.bodyText
                        entry.mood = representation.mood
                        entry.timeStamp = representation.timeStamp
                        entriesToCreate.removeValue(forKey: identifier)
                    } else { //Update TO Firebase with local if newer
                        representation.title = entry.title!
                        representation.bodyText = entry.bodyText
                        representation.mood = entry.mood!
                        representation.timeStamp = entry.timeStamp!
                        put (representation: representation)
                    }
                }
                NSLog("Creating \(entriesToCreate.count) entries from Firebase to local store.")
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
                    put(representation: entry.entryRepresentation)
                }
            } catch {
                NSLog("Error putting new local entries to Firebase: \(error)")
            }
        }
    }
}
