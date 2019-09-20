//
//  EntryRepresentation.swift
//  Journal
//
//  Created by Joshua Sharp on 9/18/19.
//  Copyright © 2019 Lambda. All rights reserved.
//

import Foundation

struct EntryRepresentation: Codable {
    var identifier: String
    var title: String
    var bodyText: String?
    var mood: String
    var timeStamp: Date
}
