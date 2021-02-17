//
//  WordnikResponse.swift
//  Wordnik
//
//  Created by User on 2/13/21.
//  Copyright © 2021 Syrym Zhursin. All rights reserved.
//

import Foundation

struct WordnikResponse: Decodable {
    var relationshipType: String
    var words: [String]
}

