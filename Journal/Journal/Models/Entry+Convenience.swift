//
//  Entry+Convenience.swift
//  Journal
//
//  Created by Joshua Sharp on 9/16/19.
//  Copyright © 2019 Lambda. All rights reserved.
//

import Foundation
import CoreData

extension Entry {
    
    var entryRepresentation: EntryRepresentation? {
        guard let title = title,
            let mood = mood,
            let identifier = identifier?.uuidString,
            let timeStamp  = timeStamp
            else { return nil}
        return EntryRepresentation(identifier: identifier, title: title, bodyText: bodyText, mood: mood, timeStamp: timeStamp)
    }
    
    convenience init(identifier: UUID = UUID(), title: String,mood: String, bodyText: String?, timeStamp: Date = Date(), context: NSManagedObjectContext) {
        
        // Setting up the generic NSManagedObject functionality of the model object
        // The generic chunk of clay
        self.init(context: context)
        
        // Once we have the clay, we can begin sculpting it into our unique model object
        self.title = title
        self.bodyText = bodyText
        self.mood = mood
        self.timeStamp = Date()
        self.identifier = UUID()
    }
    
    @discardableResult convenience init?(entryRepresentaion: EntryRepresentation, context: NSManagedObjectContext) {
        guard let identifier = UUID(uuidString: entryRepresentaion.identifier)
            else { return nil}
        
        self.init(identifier: identifier, title: entryRepresentaion.title,mood: entryRepresentaion.mood, bodyText: entryRepresentaion.bodyText, timeStamp: entryRepresentaion.timeStamp, context: context)
    }
}
