//
//  Constants.swift
//  Journal
//
//  Created by Joshua Sharp on 9/19/19.
//  Copyright © 2019 Lambda. All rights reserved.
//

import Foundation


let coreDataModelName: String = "Journal"
let baseURL = URL(string: "https://journal-d8910.firebaseio.com/")!

enum AppError: Error {
    case objectToRepFailed
}
