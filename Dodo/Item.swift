//
//  Item.swift
//  Dodo
//
//  Created by Asmit Bhardwaj on 11/04/26.
//

import Foundation
import SwiftData

@Model
class Routine {
    var name: String
    var streakCount: Int
    var lastCompletedDate: Date?
    
    init(name: String) {
        self.name = name
        self.streakCount = 0
        self.lastCompletedDate = nil
    }
    
    var isCompletedToday: Bool {
        guard let lastDate = lastCompletedDate else { return false }
        return Calendar.current.isDateInToday(lastDate)
    }
}
