//
//  EntryRepresentation.swift
//  Journal
//
//  Created by Joshua Sharp on 9/18/19.
//  Copyright © 2019 Lambda. All rights reserved.
//

import Foundation

struct EntryRepresentation: Codable {
    let identifier: String
    let title: String
    let bodyText: String?
    let mood: String
    let timeStamp: Date
}
