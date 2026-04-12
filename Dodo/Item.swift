//
//  Item.swift
//  Dodo
//
//  Created by Asmit Bhardwaj on 11/04/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
