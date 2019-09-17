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
    
    convenience init(title: String,mood: String, bodyText: String?, context: NSManagedObjectContext) {
        
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
}
